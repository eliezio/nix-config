{ pkgs, ... }: {
  programs.zsh = {
    enable = true;

    history = {
      size = 100000;
      save = 100000;
      append = true;
      findNoDups = true;
      ignoreAllDups = true;
      ignorePatterns = [ "exit" ];
      saveNoDups = true;
    };

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    zsh-abbr.enable = true;

    plugins = [
      { name = "fzf-tab"; src = pkgs.zsh-fzf-tab; }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "aws"
        "docker"
        "docker-compose"
        "safe-paste"
      ];
    };

    initContent = ''
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi
    '';

    # Example shell aliases
    shellAliases = {
      gw = "./gradlew";
      lg = "lazygit";
      mw = "./mvnw";
      vim = "nvim";
      pbcopy = "xclip -sel cl -i";  # linux-only
      pbpaste = "xclip -sel cl -o";  # linux-only
    };
  };
}
