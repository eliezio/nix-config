{ config, pkgs, ... }: {
  sops = {
    secrets.git-name = { };
    secrets.git-email = { };
    secrets.github-token = { };

    templates."gitconfig" = {
      mode = "0600";
      content = ''
        [user]
          name = ${config.sops.placeholder.git-name}
          password = ${config.sops.placeholder.github-token}
          email = ${config.sops.placeholder.git-email}
        [credential]
          helper = cache --timeout=604800
        [http]
          postBuffer = 20971520
        [init]
          defaultBranch = master
        [diff]
          renames = true
          colorMoved = true
        [fetch]
          prune = true
        [push]
          autoSetupRemote = true
          followTags = true
        [pull]
          rebase = true
        [pager]
          diff = diffnav
          show = diffnav
        [delta]
          dark = true
          side-by-side = true
          line-numbers = true
          navigate = true

          syntax-theme = "Dracula"

          plus-style = "syntax #238636"        # GitHub-style green for additions
          minus-style = "syntax #da3633"       # GitHub-style red for deletions
          plus-emph-style = "syntax #39d353"   # Brighter green for inline changes
          minus-emph-style = "syntax #f85149"  # Brighter red for inline changes

          file-style = "bold #c9d1d9"
          file-decoration-style = "#c9d1d9 ul"
          hunk-header-style = "bold #58a6ff"
          hunk-header-decoration-style = "#21262d box"
        [filter "lfs"]
          required = true
          clean = git-lfs clean -- %f
          smudge = git-lfs smudge -- %f
          process = git-lfs filter-process
        [remote "origin"]
          tagOpt = --tags
      '';
    };
  };

  programs = {
    git.enable = true;

    lazygit = {
      enable = true;
      settings = {
        gui.nerdFontsVersion = "3";
      };
    };

    zsh = {
      initContent = ''
        eval "$(wt config shell init zsh)"
      '';
      shellAliases = {
        wts  = "wt switch";
        wtl  = "wt switch -";
        wtls = "wt list";
        wtrm = "wt remove";
      };
    };
  };

  home = {
    packages = with pkgs; [
      diffnav
      tig
      worktrunk
    ];

    file = {
      ".gitconfig".source =
        config.lib.file.mkOutOfStoreSymlink
          config.sops.templates."gitconfig".path;

      ".tigrc".text = ''
        set main-view = line-number:yes,interval=5 id:yes,color date:default author:full commit-title:yes,refs,graph
        set line-graphics = utf-8
      '';

      ".config/diffnav/config.yml".text = ''
        ui:
          icons: nerd-fonts-filetype
      '';

      ".config/worktrunk/config.toml".text = ''
        worktree-path = "{{ repo_path }}/../{{ branch }}"
        skip-shell-integration-prompt = true

        [post-switch]
        tmux = "[ -n \"$TMUX\" ] && tmux rename-window {{ \"%.8s %.11s\" | format(remote_url | split(\"/\") | last, branch | replace(\"feature/\", \"\") | sanitize) }}"
      '';
    };
  };
}
