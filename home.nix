{ config, pkgs, ... }: {
  home = {
    stateVersion = "25.11";

    # Packages not explicitly configurable via Home Manager.
    packages = with pkgs; [
      httpie
      kubectl
      kubectx
      python3
      tig
      tree
      util-linux
      xclip  # linux-only
    ];

    sessionVariables = {
      EDITOR = "nvim";
      MANROFFOPT = "-c";
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };

    file.".tigrc".text = ''
      set main-view = line-number:yes,interval=5 id:yes,color date:default author:full commit-title:yes,refs,graph
      set line-graphics = utf-8
    '';
  };

  imports = [
    ./modules/zsh.nix
    ./modules/starship.nix
    ./modules/nvim.nix
  ];

  # Zsh configuration
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    awscli.enable = true;
    bat.enable = true;
    direnv = { enable = true; nix-direnv.enable = true; };
    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      extraOptions = [
        "--group"
      ];
    };
    fd.enable = true;
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [ "--extended" ];
      defaultCommand = "fd --type f";
    };
    git.enable = true;
    jq.enable = true;
    k9s.enable = true;
    lazydocker.enable = true;
    lazygit.enable = true;
    less = {
      enable = true;
      options = {
        LONG-PROMPT = true;
        IGNORE-CASE = true;
        RAW-CONTROL-CHARS = true;
      };
    };
    ripgrep.enable = true;
    zoxide = { enable = true; enableZshIntegration = true; };
  };

  # Set XDG cache directory to an absolute path
  xdg.cacheHome = "${config.home.homeDirectory}/.cache";
}
