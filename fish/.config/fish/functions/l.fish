function l
    # if eza is present, use it as opposed to built-in ls
    # see https://github.com/eza-community/eza
    if type -q eza
        eza -la --icons=auto --hyperlink --color=auto --group --links --git --git-repos --time-style=relative --total-size $argv
    else
        ls -lah --color=tty $argv
    end
end

# this should be a faster, more stripped-down version of the above; should
# probably only be needed if the directory is big, and --total-size takes too
# much to load
function ll
    # if eza is present, use it as opposed to built-in ls
    # see https://github.com/eza-community/eza
    if type -q eza
        eza -la --icons=auto --color=auto --group --links --time-style=relative $argv
    else
        ls -lah --color=tty $argv
    end
end
