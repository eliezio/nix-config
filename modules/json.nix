{ pkgs, ... }: {
  home.packages = with pkgs; [
    jd-diff-patch
    jless
    jqp
  ];

  programs.jq.enable = true;
}

