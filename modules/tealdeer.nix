{ ... }: {
  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = true;
      };
      updates = {
        tls_backend = "rustls-with-native-roots";
      };
    };
  };
}

