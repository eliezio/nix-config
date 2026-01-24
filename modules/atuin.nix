{ ... }: {
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      inline_height = 0;
      style = "auto";
      search_mode = "prefix";
    };
  };
}

