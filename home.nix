{ config, pkgs, lib, ... }:

{
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

  # Zsh configuration
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    zsh = {
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

    # Starship prompt configuration
    starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        format = lib.concatStrings [
          "$directory"
          "$git_branch"
          "$git_state"
          "$git_status"
          "$line_break"
          "$character"
        ];
        right_format = "$cmd_duration";
        add_newline = false;
        git_status = {
          format = "[$all_status$ahead_behind]($style)";
          style = "cyan";
          conflicted = " [×$count](196)";
          ahead = " ⇡$count";
          behind = " ⇣$count";
          diverged = " ⇕⇡$ahead_count⇣$behind_count";
          up_to_date = "";
          untracked = " [?$count](39)";
          stashed = " ≡$count";
          modified = " [~$count](178)";
          staged = " [+$count](178)";
          renamed = " »$count";
          deleted = " ✘$count";
        };
      };
    };

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

  # Set XDG cache directory to an absolute path
  xdg.cacheHome = "${config.home.homeDirectory}/.cache";
}
