function l
    # if eza is present, use it as opposed to built-in ls
    # see https://github.com/eza-community/eza
    if type -q eza
        eza -la --icons=auto --color=auto --group --links --git --git-repos --time-style=relative --header $argv
    else
        ls -lah --color=tty $argv
    end
end

# slower, but displays total size of dirs as well
function ll
    # if eza is present, use it as opposed to built-in ls
    # see https://github.com/eza-community/eza
    if type -q eza
        eza -la --icons=auto --color=auto --group --links --total-size --time-style=relative $argv
    else
        ls -lah --color=tty $argv
    end
end
