with import <nixpkgs> {};

let
  javaShell = { version }:
    let
      jdk = javaPackages.compiler.temurin-bin."jdk-${version}";
    in
      mkShell {
        buildInputs = [ jdk ];
        shellHook = ''
          export JAVA_HOME=${jdk}
          export PATH=$JAVA_HOME/bin:$PATH
          echo "Using JDK $JAVA_HOME"
        '';
      };
in
  javaShell { version = "21"; }
