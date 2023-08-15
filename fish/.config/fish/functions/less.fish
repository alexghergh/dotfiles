# a frontend to less which also works to list archive contents
function less
    set -l i 1
    for arg in $argv
        set argv[$i] (mktemp)
        switch $arg
            case '*.zip'
                zip -sf $arg > $argv[$i]
            case '*.bz2'
                bunzip2 -c $arg > $argv[$i]
            case '*.tar.gz'
                tar --list -f $arg > $argv[$i]
            case '*.gz' '*.Z'
                zcat $arg > $argv[$i]
        end
        set i (math $i + 1)
    end
    command less $argv
end
