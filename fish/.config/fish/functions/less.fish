# a frontend to less which also works to list archive contents
function less
    # skip this overwrite in non-interactive shells
    if not status is-interactive
        command less $argv
        return $status
    end

    set -l i 1
    set -l temp_files # temp files are removed at the end
    for arg in $argv
        switch $arg
            case '*.zip'
                set -l temp_file (mktemp); or return
                set -a temp_files $temp_file
                set argv[$i] $temp_file
                zip -sf $arg > $temp_file
            case '*.bz2'
                set -l temp_file (mktemp); or return
                set -a temp_files $temp_file
                set argv[$i] $temp_file
                bunzip2 -c $arg > $temp_file
            case '*.tar.gz'
                set -l temp_file (mktemp); or return
                set -a temp_files $temp_file
                set argv[$i] $temp_file
                tar --list -f $arg > $temp_file
            case '*.gz' '*.Z'
                set -l temp_file (mktemp); or return
                set -a temp_files $temp_file
                set argv[$i] $temp_file
                zcat $arg > $temp_file
        end
        set i (math $i + 1)
    end

    command less -MNi $argv
    set -l less_status $status

    if test (count $temp_files) -gt 0
        command rm -f $temp_files
    end

    return $less_status
end
