# a frontend to less which also works to list archive contents
function less
    set -l i 1
    for arg in $argv
        switch $arg
            case '*.zip'
                set argv[$i] (mktemp)
                zip -sf $arg > $argv[$i]
            case '*.bz2'
                set argv[$i] (mktemp)
                bunzip2 -c $arg > $argv[$i]
            case '*.tar.gz'
                set argv[$i] (mktemp)
                tar --list -f $arg > $argv[$i]
            case '*.gz' '*.Z'
                set argv[$i] (mktemp)
                zcat $arg > $argv[$i]
        end
        set i (math $i + 1)
    end
    command less -MNi $argv
end
