function rm
    # only works in interactive shells, as it is blocking
    if status is-interactive
        command rm -I $argv
    else
        command rm $argv
    end
end
