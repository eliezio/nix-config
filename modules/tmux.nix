{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    prefix = "C-s";
    mouse = true;
    baseIndex = 1;
    historyLimit = 20000;
    keyMode = "vi";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_window_text "#W"
          set -g @catppuccin_window_current_text "#W"
          set -g @catppuccin_window_flags "icon"
          set -g status-left "#{E:@catppuccin_status_session}"
          set -gF status-right "#{E:@catppuccin_status_date_time}"
          set -g @catppuccin_date_time_text " %d %b %H:%M"
        '';
      }
    ];
    extraConfig = ''
      set -g detach-on-destroy off
      set -g renumber-windows on
      set -g set-clipboard on
      set -g status-position top
      set -g pane-active-border-style 'fg=magenta,bg=default'
      set -g pane-border-style 'fg=brightblack,bg=default'
      set-hook -g -w pane-focus-in "set-option -Fw pane-border-status '#{?#{e|>:#{window_panes},1},top,off}'"
      set -g pane-border-format "#{pane_index} #{s|$HOME|~|:pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind a send-prefix
      # Some Byobu keybindings
      bind-key -n M-Left previous-window
      bind-key -n M-Right next-window
      bind-key -n M-Up switch-client -p
      bind-key -n M-Down switch-client -n
      bind-key -n S-Left select-pane -L
      bind-key -n S-Right select-pane -R
      bind-key -n S-Up select-pane -U
      bind-key -n S-Down select-pane -D
      bind-key -n M-NPage copy-mode \; send-keys NPage
      bind-key -n M-PPage copy-mode \; send-keys PPage
    '';
  };
}

