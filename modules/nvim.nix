{
  programs.nixvim = {
    enable = true;

    globals.mapleader = " ";

    ####################################################################
    # Core options
    ####################################################################
    opts = {
      number = true;
      relativenumber = true;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      smartindent = true;
      signcolumn = "yes";
      updatetime = 250;
      foldlevelstart = 99;
    };

    ####################################################################
    # Plugins (declarative, no Lazy)
    ####################################################################
    plugins = {
      ##################################################################
      # UI
      ##################################################################
      lualine.enable = true;
      bufferline.enable = true;
      web-devicons.enable = true;

      ##################################################################
      # Treesitter (no downloads at runtime)
      ##################################################################
      treesitter = {
        enable = true;
        highlight.enable = true;
        indent.enable = true;
        folding.enable = true;
      };

      ##################################################################
      # Completion
      ##################################################################
      cmp = {
        enable = true;

        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
        };
      };

      ##################################################################
      # Telescope
      ##################################################################
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;

        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fo" = "oldfiles";     # recent files
          "<leader>fw" = "live_grep";    # find word
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
        };
      };

      ##################################################################
      # Git
      ##################################################################
      gitsigns.enable = true;

      ##################################################################
      # Misc
      ##################################################################
      which-key.enable = true;
      comment.enable = true;
      todo-comments.enable = true;
      trouble.enable = true;
      nvim-surround.enable = true;
    };

    ####################################################################
    # Colorscheme
    ####################################################################
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
      };
    };
  };
}
