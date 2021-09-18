#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

helpers="$CURRENT_DIR/../scripts/"

color1="#00347a"
color2="#0753a1"
color3="#0070ac"
color4="#2969b1"
color5="#765fb7"
color6="#6f47b9"
color7="#492299"
color8="#2a1274"
color9="#110944"
color10="#010511"

# modes
tmux set -g clock-mode-colour colour5
tmux set -g mode-style 'fg=colour39,bold,reverse'
tmux set -g message-style 'fg=colour255 bg=colour234 bold'

# panes
tmux set -g pane-border-style 'fg=colour9 bg=colour235'
tmux set -g pane-active-border-style 'fg=colour232 bg=colour39'

# statusbar
tmux set -g status-position bottom
tmux set -g status-justify left
tmux set -g status-style 'bg=colour234 fg=colour250 dim'

tmux set -g status-left ''
tmux set -g status-left-length 30

battery_status="#[bold][#($helpers/battery_percent)%]#[nobold] #{?#{==:#($helpers/battery_status),Discharging},Disch.,Ch.}"
song_info="Playing: #[bold]#($helpers/song_info)#[nobold]"

tmux set -g status-right "#[fg=$color7]#[fg=colour249,bg=$color7] $song_info #[fg=#$color6]#[fg=$color10,bg=#$color6] $battery_status #[fg=$color5]#[fg=$color10,bg=$color5] Session: #S #[fg=$color3]#[fg=$color10,bg=$color3] %A %d/%m #[fg=$color2]#[fg=$color10,bg=$color2] %T #[fg=$color1]"

tmux set -g status-right-length 200

current_window_color="#a595d0"

tmux setw -g window-status-current-style "bg=colour234 bold"
tmux setw -g window-status-current-format " #[fg=$current_window_color,bg=colour240] #[fg=$current_window_color]#I#[fg=colour250,bg=colour240]:#[fg=colour255,bg=colour240]#W#[fg=$current_window_color,bg=colour240]#F #[fg=colour240,bg=colour234]"

window_color=$color5

tmux setw -g window-status-style "bg=colour234"
tmux setw -g window-status-format " #[fg=colour234,bg=colour236] #[fg=$window_color]#I#[fg=colour250,bg=colour236]:#[fg=colour245,bg=colour236]#W#[fg=colour245,bg=colour236]#F #[fg=colour236,bg=colour234]"

tmux setw -g window-status-separator ''
