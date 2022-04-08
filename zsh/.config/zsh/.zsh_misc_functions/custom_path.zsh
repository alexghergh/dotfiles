##
## Custom path
##

## return a custom path, based on the environment variable
## _CURRENT_PATH_MODE (can be SHORT or LONG)
##
## SHORT - display only the first character of each directory, or the first two
##          characters if it is a dot directory
##
## LONG - display the full path
##
_custom_current_path() {
    emulate -LR zsh
    local mode current_path slash_first new_path
    mode=${_CURRENT_PATH_MODE:-LONG}

    # check if the user supplied mode is a valid mode
    if [[ ! "SHORT LONG" =~ "$mode" ]]; then
        mode="LONG"
    fi

    # get the current path (respecting user's home directory)
    current_path=$(print -P %~)

    case $mode in
        ("SHORT") # short mode

                # if the path begins with a slash instead of a tilde, save it
                if [[ "$current_path" && $current_path[1] =~ "/" ]]; then
                    slash_first=1
                fi

                # split the current path on path segments ('/')
                current_path=(${(s:/:)current_path})

                # create the shortened path with just the first character of each
                # directory, or the first two characters if the directory is a dot
                # dir
                new_path=()
                for elem in $current_path; do
                    if [[ "${elem[1]}" = "." ]]; then
                        new_path+=("${elem[1]}${elem[2]}")
                    else
                        new_path+=(${elem[1]})
                    fi
                done

                # join the segments again
                new_path=${(j:/:)new_path}

                # if the working dir had a slash, then prepend it again
                # (since it got lost when we split on slashes)
                if (( slash_first == 1 )); then
                    new_path="/$new_path"
                fi

                echo "$new_path"
            ;;
        ("LONG") # long mode
                print -P %~
            ;;
    esac
}
