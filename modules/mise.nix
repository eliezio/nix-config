{ lib, pkgs, ... }:
let
  certsDir = ../certs;
  certEntries = builtins.readDir certsDir;
  certFileNames = builtins.sort builtins.lessThan (builtins.filter (name:
    certEntries.${name} == "regular" &&
    (lib.hasSuffix ".crt" name || lib.hasSuffix ".pem" name)
  ) (builtins.attrNames certEntries));
  certFilesPyList = lib.concatMapStringsSep ", " (name: ''"${certsDir}/${name}"'') certFileNames;

  jvmImportPemCacerts = pkgs.writeTextFile {
    name = "jvm-import-pem-cacerts";
    executable = true;
    destination = "/bin/jvm-import-pem-cacerts";
    text = ''
      #!${pkgs.python3}/bin/python3
      import argparse
      import os
      import pathlib
      import re
      import shutil
      import subprocess
      import sys

      OPENSSL = "${pkgs.openssl}/bin/openssl"
      CERT_FILES = [${certFilesPyList}]


      def run(cmd, check=True):
          return subprocess.run(cmd, check=check, text=True, capture_output=True)


      def normalize_fp(value):
          return value.replace(":", "").strip().upper()


      def cert_fingerprint(cert_path):
          result = run([OPENSSL, "x509", "-in", cert_path, "-noout", "-fingerprint", "-sha1"])
          # Output example: SHA1 Fingerprint=AA:BB:...
          fingerprint = result.stdout.split("=", 1)[-1].strip()
          return normalize_fp(fingerprint)


      def find_java_home(explicit_java_home):
          if explicit_java_home:
              return explicit_java_home

          java_bin = shutil.which("java")
          if not java_bin:
              return None

          java_real = os.path.realpath(java_bin)
          return str(pathlib.Path(java_real).parent.parent)


      def find_cacerts(java_home):
          candidates = [
              pathlib.Path(java_home) / "lib" / "security" / "cacerts",
              pathlib.Path(java_home) / "jre" / "lib" / "security" / "cacerts",
          ]
          for candidate in candidates:
              if candidate.exists():
                  return str(candidate)
          return None


      def find_keytool(java_home):
          candidate = pathlib.Path(java_home) / "bin" / "keytool"
          if candidate.exists() and os.access(candidate, os.X_OK):
              return str(candidate)
          return shutil.which("keytool")


      def parse_keystore_fingerprints(keytool_bin, cacerts_path, storepass):
          result = run([keytool_bin, "-list", "-v", "-keystore", cacerts_path, "-storepass", storepass])
          by_fingerprint = {}
          aliases = set()
          current_alias = None
          for line in result.stdout.splitlines():
              alias_match = re.match(r"^Alias name:\s*(.+)$", line)
              if alias_match:
                  current_alias = alias_match.group(1).strip()
                  aliases.add(current_alias)
                  continue

              sha1_match = re.match(r"^\s*SHA1:\s*([0-9A-Fa-f:]+)$", line)
              if sha1_match and current_alias:
                  by_fingerprint[normalize_fp(sha1_match.group(1))] = current_alias
          return by_fingerprint, aliases


      def unique_alias(base_alias, fingerprint, aliases):
          suffix = fingerprint[:4].lower()
          candidate = f"{base_alias}-{suffix}"
          if candidate not in aliases:
              return candidate
          n = 1
          while True:
              extended = f"{candidate}-{n}"
              if extended not in aliases:
                  return extended
              n += 1


      def import_cert(keytool_bin, cacerts_path, storepass, alias_name, cert_path, use_sudo):
          cmd = [
              keytool_bin,
              "-importcert",
              "-noprompt",
              "-trustcacerts",
              "-alias",
              alias_name,
              "-file",
              cert_path,
              "-keystore",
              cacerts_path,
              "-storepass",
              storepass,
          ]
          if use_sudo:
              cmd = ["sudo", *cmd]
          subprocess.run(cmd, check=True)


      def main():
          parser = argparse.ArgumentParser()
          parser.add_argument("--java-home", default="")
          args = parser.parse_args()

          cert_files = [c for c in CERT_FILES if os.path.isfile(c)]
          if not cert_files:
              print("Skipping JVM truststore import; no PEM/CRT cert files configured.", file=sys.stderr)
              return 0

          java_home = find_java_home(args.java_home)
          if not java_home:
              print("Skipping JVM truststore import; java is not available in PATH.", file=sys.stderr)
              return 0

          cacerts_path = find_cacerts(java_home)
          if not cacerts_path:
              print(f"Skipping JVM truststore import; could not find cacerts under {java_home}", file=sys.stderr)
              return 0

          keytool_bin = find_keytool(java_home)
          if not keytool_bin:
              print(f"Skipping JVM truststore import; keytool not found for {java_home}", file=sys.stderr)
              return 0

          storepass = os.environ.get("JVM_CACERTS_STOREPASS", "changeit")
          use_sudo = not os.access(cacerts_path, os.W_OK)

          try:
              by_fingerprint, aliases = parse_keystore_fingerprints(
                  keytool_bin, cacerts_path, storepass
              )
          except subprocess.CalledProcessError as exc:
              print(exc.stderr.strip(), file=sys.stderr)
              return exc.returncode

          imported = 0
          skipped = 0
          for cert_path in cert_files:
              fingerprint = cert_fingerprint(cert_path)
              if fingerprint in by_fingerprint:
                  skipped += 1
                  continue

              base_alias = pathlib.Path(cert_path).stem
              alias_name = unique_alias(base_alias, fingerprint, aliases)

              import_cert(
                  keytool_bin,
                  cacerts_path,
                  storepass,
                  alias_name,
                  cert_path,
                  use_sudo,
              )
              aliases.add(alias_name)
              by_fingerprint[fingerprint] = alias_name
              imported += 1

          print(
              f"JVM truststore sync complete for {java_home}: imported={imported}, skipped={skipped}"
          )
          return 0


      if __name__ == "__main__":
          raise SystemExit(main())
    '';
  };
in {
  home.packages = [ jvmImportPemCacerts ];

  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile = {
    "mise/config.toml".text = ''
      [settings]
      experimental = true

      [hooks]
      postinstall = "~/.config/mise/hooks/postinstall.sh"
    '';

    "mise/hooks/postinstall.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        tools_json="''${MISE_INSTALLED_TOOLS:-[]}"
        helper="${jvmImportPemCacerts}/bin/jvm-import-pem-cacerts"
        mise_bin="${pkgs.mise}/bin/mise"

        if [ -z "$tools_json" ]; then
          exit 0
        fi

        has_java="$(${pkgs.jq}/bin/jq -e 'any(.[]; (. == "java") or (.name == "java"))' <<<"$tools_json" >/dev/null 2>&1 && echo 1 || echo 0)"

        [ "$has_java" = "1" ] || exit 0

        java_home="$($mise_bin where java 2>/dev/null || true)"
        if [ -d "$java_home" ]; then
          "$helper" --java-home "$java_home"
        else
          "$helper"
        fi
      '';
    };
  };
}

