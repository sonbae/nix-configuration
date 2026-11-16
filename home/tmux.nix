# tmux, ported from github.com/sonbae/dotfiles (.tmux.conf).
# Writes ~/.config/tmux/tmux.conf.
{ pkgs, lib, ... }:

let
  # The original status bar read /proc/loadavg, which only exists on Linux.
  # macOS reports load averages through sysctl as "{ 1.23 1.45 1.67 }".
  loadavg =
    if pkgs.stdenv.hostPlatform.isDarwin
    then ''sysctl -n vm.loadavg | cut -d " " -f 2-4''
    else ''cut -d " " -f 1-3 /proc/loadavg'';
in
{
  programs.tmux = {
    enable = true;

    # Backtick as prefix (replaces C-b). Press ` twice to send a literal `.
    prefix = "`";

    # Short delay after Esc so vim responds quickly.
    escapeTime = 50;

    extraConfig = ''
      # - to split vertically, | to split horizontally, both in the current dir
      bind-key - split-window -v -c '#{pane_current_path}'
      bind-key | split-window -h -c '#{pane_current_path}'
      unbind '"'
      unbind %

      # move between panes with Alt-<vim keys>
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # resize panes with Alt-Shift-<vim keys>
      bind -n M-H resize-pane -L 5
      bind -n M-J resize-pane -D 5
      bind -n M-K resize-pane -U 5
      bind -n M-L resize-pane -R 5

      # theme
      set -g status-bg black
      set -g status-fg white
      set -g window-status-current-style fg=black,bg=white,bold
      set -g status-interval 60
      set -g status-left-length 30
      set -g status-left '#[fg=green](#S) #(whoami)   '
      set -g status-right '#[fg=yellow]#(${loadavg})#[default] #[fg=white]%H:%M#[default]'
    '';
  };
}
