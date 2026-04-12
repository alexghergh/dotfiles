function mkcd --description "mkdir and cd into path"
    # this doesn't work with multiple args
    if test (count $argv) -ne 1
        echo "usage: mkcd <path>" >&2
        return 1
    end

    mkdir -p $argv[1]; or return
    cd $argv[1]
end
