{ config, pkgs, ... }: {
  sops = {
    defaultSopsFile = ./user.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };

  home = {
    stateVersion = "26.05";

    # Packages not explicitly configurable via Home Manager.
    packages = with pkgs; [
      below
      curlie
      httpie
      util-linux
      xclip  # linux-only
    ];

    sessionVariables = {
      MANROFFOPT = "-c";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };
  };

  imports = [
    ./modules/atuin.nix
    ./modules/awscli.nix
    ./modules/bat.nix
    ./modules/fd.nix
    ./modules/fzf.nix
    ./modules/git.nix
    ./modules/gradle.nix
    ./modules/json.nix
    ./modules/kubernetes.nix
    ./modules/lazydocker.nix
    ./modules/less.nix
    ./modules/lsd.nix
    ./modules/mise.nix
    ./modules/nvim.nix
    ./modules/ripgrep.nix
    ./modules/starship.nix
    ./modules/tealdeer.nix
    ./modules/tmux.nix
    ./modules/yazi.nix
    ./modules/zsh.nix
    ./modules/zoxide.nix
  ];

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };

  # Set XDG cache directory to an absolute path
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig = {
        PROJECTS = "${config.home.homeDirectory}/Projects";
      };
    };
  };
}
