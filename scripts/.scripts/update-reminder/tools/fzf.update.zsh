#!/usr/bin/env zsh

##
# Check that fzf is locally installed and is updated to the latest version.
##

local RED YELLOW CLEAR BOLD
RED='\033[0;31m'
YELLOW='\033[1;33m'
CLEAR='\033[0m'

local install_dir

function _print_message() {
    emulate -LR zsh
    local message color
    message=$1
    color=$2

    echo -n "$color"
    echo "fzf: $message"
    echo -n "$CLEAR"
}

# check whether fzf is already installed on the system
function _check_fzf_local_install() {
    emulate -LR zsh
    local message

    message=$(cat <<EOF
Checking to see if fzf is in PATH...
EOF
)
    _print_message $message $CLEAR

    # check if the fzf command works
    if command -v fzf > /dev/null 2>&1; then

        install_dir=$(command -v fzf)

        message=$(cat <<EOF
Found fzf executable at $install_dir. PATH is set correctly.
EOF
)
        _print_message $message $CLEAR

        return 0
    fi

    message=$(cat <<EOF
Didn't find fzf through PATH, checking if the directory is present...
EOF
)
    _print_message $message $YELLOW

    # if the fzf command doesn't work, there may be path issues
    # check if the folder is in the user's home and notify the user
    if [[ -d "$HOME/.fzf" ]]; then

        install_dir="$HOME/.fzf"

        message=$(cat <<EOF
Found fzf in $install_dir. The PATH is NOT set correctly, check your config
files.
EOF
)
        _print_message $message $YELLOW

        return 1
    fi

    message=$(cat <<EOF
Fzf is not installed on the system! To install, go to:

https://github.com/junegunn/fzf#using-git

and follow the instructions.
EOF
)
    _print_message $message $RED

    # we did not find fzf installed
    return 1
}

function _check_fzf_latest_version() {
    emulate -LR zsh

    local remote_short_stat message

    # get the status of the remote branch
    # this implies there is an active internet connection
    remote_short_stat=$(cd $install_dir && git remote update && git status -uno)

    # if the status contains the word "behind", assume there are updates
    if [[ $remote_short_stat =~ "behind" ]]; then
        message=$(cat <<EOF
Fzf is NOT up-to-date. Please go to:

    https://github.com/junegunn/fzf#upgrading-fzf

to update.
EOF
)
        _print_message $message $RED

        return 1

     else
         echo "Fzf is up-to-date."
         return 0
     fi
}

function check_fzf() {
    emulate -LR zsh
    local message

    message="Checking if fzf is installed on the system..."
    _print_message $message $CLEAR

    _check_fzf_local_install || return 1

    message="Checking if fzf is up-to-date..."
    _print_message $message $CLEAR

    _check_fzf_latest_version || return 1

    message="Fzf installation is correct and up-to-date!!"
    _print_message $message $CLEAR

    return 0
}
