{ lib, ... }: {
  programs.starship = {
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
}
