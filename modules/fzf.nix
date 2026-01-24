{ ... }: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [ "--extended" ];
    defaultCommand = "fd --type f";
  };
}

