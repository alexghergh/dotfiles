#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

helpers="$CURRENT_DIR/../scripts/"

color1="#00347a"
color2="#8ab977"
color3="#a9a9af"
color4="#2969b1"
color5="#765fb7"
color6="#a595d0"
color7="#282c34"
color8="#2a1274"
color9="#3d4451"
color10="#3e4452"

# modes
tmux set -g clock-mode-colour $color2
tmux set -g mode-style "fg=$color2,bold,reverse"
tmux set -g message-style "fg=colour255 bg=colour234"

# panes
tmux set -g pane-border-style "fg=$color3 bg=colour235"
tmux set -g pane-active-border-style "fg=colour232 bg=$color2"

# statusbar
tmux set -g status-position bottom
tmux set -g status-justify left
tmux set -g status-style "bg=$color7 fg=colour250 dim"

tmux set -g status-left "#[fg=$color9,bg=$color2] #S "
tmux set -g status-left-length 30

battery_status="#[bold]#($helpers/battery_percent)%#[nobold] #{?#{==:#($helpers/battery_status),Discharging},Disch.,Ch.}"
song_info="♪ #($helpers/song_info)"
cpu_temp="#($helpers/cpu_temp)"

tmux set -g status-right "#[fg=$color2,bg=$color7] $song_info #[fg=$color3,bg=#$color10] $cpu_temp $battery_status |#[fg=$color3,bg=$color10] %A %d/%m/%Y #[bold]#[fg=$color9,bg=$color2] %T #[fg=$color9]"

tmux set -g status-right-length 150

# current/active window

l_current_window_fg_style=$color3
l_current_window_bg_style=$color10
l_current_window_text=$l_current_window_fg_style

tmux setw -g window-status-current-style "bold"
tmux setw -g window-status-current-format "#[fg=$l_current_window_text,bg=$l_current_window_bg_style] #I | #[fg=$l_current_window_text,bg=$l_current_window_bg_style]#W#[fg=$l_current_window_text,bg=$l_current_window_bg_style]#F #[fg=$l_current_window_fg_style]"

# other windows

l_window_fg_style=$color2
l_window_bg_style=$color7
l_window_text=$l_window_fg_style

tmux setw -g window-status-style ""
tmux setw -g window-status-format "#[fg=$l_window_text,bg=$l_window_bg_style] #I | #[fg=$l_window_text,bg=$l_window_bg_style]#W#[fg=$l_window_text,bg=$l_window_bg_style]#F #[fg=$l_window_fg_style,bg=$l_window_bg_style]"

tmux setw -g window-status-separator ""
