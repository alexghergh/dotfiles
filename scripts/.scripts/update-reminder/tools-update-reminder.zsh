#!/usr/bin/env zsh

################################################################################
#
# Author: alexghergh
#
# The script is meant to check all the installed tools and alert the user if one
# of them needs updating.
#
# The script can also just be used as a reminder of tools that need updating,
# because oftentimes I simply forget to update stuff (because I forget about all
# the stuff in the first place).
#
# The script is meant to be used together with package manager hooks
# (pacman/apt etc.)
#
################################################################################

local CURRENT_DIR TOOLS_DIR

CURRENT_DIR="${0:A:h}"
TOOLS_DIR="$CURRENT_DIR/tools"

main() {

    # TODO tools to check
    # fzf
    # pyenv
    # zsh antidote
    # neovim (ubuntu)
    # tmux (ubuntu)
    # neovim plugins
    # neovim external stuff (pynvim, node package)

    source "$TOOLS_DIR"/fzf.update.zsh

    check_fzf

    emulate -LR zsh
}

main
