{ ... }: {
  programs.less = {
    enable = true;
    options = {
      LONG-PROMPT = true;
      IGNORE-CASE = true;
      RAW-CONTROL-CHARS = true;
    };
  };
}

