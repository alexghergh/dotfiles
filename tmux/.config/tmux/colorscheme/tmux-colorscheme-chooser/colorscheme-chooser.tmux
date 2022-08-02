#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# get the current colorscheme set in the .tmux.conf file and source it
current_colorscheme=$(tmux show-option -gqv "@colorscheme")
default_colorscheme="sea"

if [ -z "$current_colorscheme" ]; then
  current_colorscheme=$default_colorscheme
fi

if [ -s "$CURRENT_DIR/colorschemes/$current_colorscheme.sh" ]; then
  source "$CURRENT_DIR/colorschemes/$current_colorscheme.sh";
else
  source "$CURRENT_DIR/colorschemes/$default_colorscheme.sh";
fi
