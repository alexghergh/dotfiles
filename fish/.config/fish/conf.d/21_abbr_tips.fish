# abbreviation reminders
#
# this is a small local version of fish-abbreviation-tips
# it builds a cache from the abbreviations already defined by 20_abbr.fish, then
# reminds when a manually typed command starts with one of those expansions
#
# DON'T RENAME THIS FILE; this _needs_ to run after 20_abbr.fish, since it
# caches abbrs already defined there

# don't define in non-interactive shells
if not status is-interactive
    return
end

set -g __abbr_reminder_used 0
set -g __abbr_reminder_keys
set -g __abbr_reminder_values

# fish_postexec receives the expanded command, so without this flag "gs" and
# manually typed "git status" look identical after execution; because of that,
# we need to continuously scan the commandline typed characters and set a flag
# to decide whether the user typed the abbr or not
function __abbr_reminder_mark_if_used
    test $__abbr_reminder_used = 1; and return

    set -l token (string trim -- (commandline --current-token))

    if abbr -q -- $token
        set -g __abbr_reminder_used 1
    else
        set -g __abbr_reminder_used 0
    end
end

# space normally inserts a literal space and expands abbreviations; this wrapper
# records whether the current token was an abbreviation before fish expands it
function __abbr_reminder_bind_space
    __abbr_reminder_mark_if_used
    commandline -i ' '
    commandline -f expand-abbr
end

# enter normally executes the commandline; this wrapper records whether the
# commandline is an abbreviation before execution expands it
function __abbr_reminder_bind_newline
    __abbr_reminder_mark_if_used
    commandline -f execute
end

# bind the above wrappers
bind ' ' __abbr_reminder_bind_space
bind \n __abbr_reminder_bind_newline
bind \r __abbr_reminder_bind_newline

# the main part of the functionality; runs on fish_postexec, i.e. after the user
# submits a command
function __abbr_reminder_show --on-event fish_postexec
    if test $__abbr_reminder_used = 1
        set -g __abbr_reminder_used 0
        return
    end

    set -l cmd (string trim -- (string replace -r -a '\s+' ' ' -- "$argv"))
    set -l words (string split ' ' -- $cmd)
    set -q words[1]; or return

    # if the command itself is an abbreviation name, do not remind
    abbr -q -- $cmd; and return

    # avoid reminders for typos or unknown commands
    type -q -- $words[1]; or return

    # go searching for the matching abbr
    set -l best_index
    set -l best_length 0
    for index in (seq (count $__abbr_reminder_values))
        set -l expansion $__abbr_reminder_values[$index]
        set -l pattern '^\s*'(string escape --style=regex -- $expansion)'(\s|$)'

        if string match -qr -- $pattern $cmd
            set -l expansion_length (string length -- $expansion)
            if test $expansion_length -gt $best_length
                set best_index $index
                set best_length $expansion_length
            end
        end
    end

    set -q best_index[1]; or return

    # print the longest matching abbreviation expansion
    set -l abbr $__abbr_reminder_keys[$best_index]
    set -l expansion $__abbr_reminder_values[$best_index]
    printf '\n💡 \e[1m%s\e[0m => %s\n' $abbr "$expansion"
end

# run init to build up a cache of abbrs; this way, we don't always parse abbrs
# on every typed command
function __abbr_reminder_init
    set -g __abbr_reminder_keys
    set -g __abbr_reminder_values

    # abbr --show prints importable definitions; parse the stable part after
    # "--" so options like "--position anywhere" do not affect extraction
    for abbr_def in (abbr --show)
        # dynamic abbreviations do not have one fixed expansion to compare, so
        # we need to skip those
        string match -q -- '*--regex*' $abbr_def; and continue
        string match -q -- '*--function*' $abbr_def; and continue

        # parse the abbr and its expansion and save those for later
        set -l abbr_parts (string split -m1 ' ' -- (string replace -r '.*-- ' '' -- $abbr_def))
        test (count $abbr_parts) -eq 2; or continue

        set -a __abbr_reminder_keys $abbr_parts[1]
        set -a __abbr_reminder_values (string unescape -- $abbr_parts[2])
    end
end

__abbr_reminder_init
