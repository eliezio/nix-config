{ ... }: {
  programs.lsd = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      sorting.dir-grouping = "first";
      date = "+%b %e %H:%M";
    };
  };
}

