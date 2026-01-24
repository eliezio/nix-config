{ pkgs, ... }: {
  home.packages = [
    pkgs.kubectl
    pkgs.kubectx
  ];

  programs.k9s.enable = true;
}


