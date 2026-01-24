{ pkgs, ... }: {
  programs.zsh.shellAliases.gw = "./gradlew";

  home = {
    packages = [ pkgs.gradle ];

    file = {
      ".gradle/gradle.properties".text = ''
        org.gradle.daemon=true
        org.gradle.parallel=true
      '';
    };
  };
}
