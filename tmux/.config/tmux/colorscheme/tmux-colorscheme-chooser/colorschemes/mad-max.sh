#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

helpers="$CURRENT_DIR/../scripts/"

color1="#371200"
color2="#ee7615"
color3="#f3891c"
color4="#f9a245"
color5="#fdccae"
color6="#aca59f"
color7="#1e6d6a"
color8="#00595d"
color9="#28423f"
color10="#020609"

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

tmux set -g status-right "#[fg=$color5]#[fg=colour236,bg=$color5] $song_info #[fg=#$color4]#[fg=colour236,bg=#$color4] $battery_status #[fg=$color3]#[fg=colour236,bg=$color3] Session: #S #[fg=$color7]#[fg=$color5,bg=$color7] %A %d/%m #[fg=$color8]#[fg=$color5,bg=$color8] %T #[fg=$color1]"

tmux set -g status-right-length 200

tmux setw -g window-status-current-style "bg=colour234 bold"
tmux setw -g window-status-current-format " #[fg=colour39,bg=colour240] #[fg=colour45]#I#[fg=colour250,bg=colour240]:#[fg=colour255,bg=colour240]#W#[fg=colour45,bg=colour240]#F #[fg=colour240,bg=colour234]"

tmux setw -g window-status-style "bg=colour234"
tmux setw -g window-status-format " #[fg=colour234,bg=colour236] #[fg=colour39]#I#[fg=colour250,bg=colour236]:#[fg=colour245,bg=colour236]#W#[fg=colour245,bg=colour236]#F #[fg=colour236,bg=colour234]"

tmux setw -g window-status-separator ''
