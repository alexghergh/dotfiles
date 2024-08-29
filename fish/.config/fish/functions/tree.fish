function tree
    # if eza is present, use it as opposed to built-in tree
    # see https://github.com/eza-community/eza
    if type -q eza
        eza --long --tree --level=3 $argv
    else
        command tree $argv
    end
end
