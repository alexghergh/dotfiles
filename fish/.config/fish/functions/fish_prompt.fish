function fish_prompt
    set -l local_status $status # needs to be first thing

    # colors (borrowed from fish's theme colors)
    set -l normal (set_color normal)
    set -l eoc_separator_color $fish_color_error
    set -l jobs_present_color $fish_color_error
    set -l jobs_absent_color $fish_color_command
    set -l username_color $fish_color_param
    set -l hostname_color $fish_color_keyword
    set -l cwd_color $fish_color_redirection
    set -l vcs_color $fish_color_quote
    set -l git_dirty_color $fish_color_error
    set -l git_staged_color $fish_color_quote
    set -l git_untracked_color $fish_color_comment
    set -l arrow_color $fish_color_autosuggestion
    set -l sign_color $fish_color_autosuggestion
    set -l cmd_duration_color $fish_color_comment

    # separator (previous command's output from current prompt)
    echo
    echo -ns (set_color $eoc_separator_color) "──────────────────────────────────────────────────"
    echo

    # jobs
    jobs -q
    and set_color $jobs_present_color
    or set_color $jobs_absent_color
    echo -ns "(" (count (string split "\n" (jobs -p))) ") " $normal

    # username and host
    echo -ns (set_color $username_color) "$USER" $normal @ (set_color $hostname_color) (prompt_hostname) $normal

    # path (git-aware: repo name + subpath in bold)
    set -l toplevel (git rev-parse --show-toplevel 2>/dev/null)
    if test $status -eq 0
        # get the 2 parts of the path (git and non-git)
        set -l repo_name (basename -- $toplevel)
        set -l repo_parent (dirname -- $toplevel)
        set -l subpath (string replace -- "$toplevel" "" "$PWD")

        # shorten parent path, same as fish's prompt_pwd does
        # also respects fish_prompt_pwd_full_dirs (toggled by Ctrl-o Ctrl-r)
        set -l short_parent (string replace -- "$HOME" "~" "$repo_parent")
        set -l full_dirs $fish_prompt_pwd_full_dirs
        test -z "$full_dirs"; and set full_dirs 1
        set -l dir_length $fish_prompt_pwd_dir_length
        test -z "$dir_length"; and set dir_length 1
        if test $dir_length -gt 0 -a $full_dirs -lt 999
            set short_parent (string replace -ar '(\.?[^/]{'"$dir_length"'})[^/]*/' '$1/' -- "$short_parent/")
            set short_parent (string replace -r '/$' '' -- "$short_parent")
            # shorten git subpath too, keeping last component full; this will
            # keep repo name + last element full, shortening other paths
            set subpath (string replace -ar '(\.?[^/]{'"$dir_length"'})[^/]*/' '$1/' -- "$subpath")
        end

        echo -ns ":" (set_color $cwd_color) "$short_parent/" \
            (set_color --bold $cwd_color) "$repo_name$subpath" $normal
    else
        # no git repo
        echo -ns ":" (set_color $cwd_color) (prompt_pwd) $normal
    end

    # vcs info (branch + status indicators inside parens)
    set -l git_info (fish_vcs_prompt)
    if test -n "$git_info"
        # git status indicators: * unstaged, + staged, ? untracked
        set -l dirty ""
        set -l staged ""
        set -l untracked ""
        git diff --quiet 2>/dev/null; or set dirty "*"
        git diff --cached --quiet 2>/dev/null; or set staged "+"
        test -n "$(git ls-files --others --exclude-standard 2>/dev/null | head -1)"
            and set untracked "?"

        # strip trailing ) so we can append indicators inside the parens
        set -l git_open (string replace -r '\)$' '' -- $git_info)
        echo -ns (set_color --bold $vcs_color) $git_open
        if test -n "$dirty$staged$untracked"
            echo -ns " "
            test -n "$dirty"; and echo -ns (set_color --bold $git_dirty_color) $dirty
            test -n "$staged"; and echo -ns (set_color --bold $git_staged_color) $staged
            test -n "$untracked"; and echo -ns (set_color --bold $git_untracked_color) $untracked
        end
        echo -ns (set_color --bold $vcs_color) ")" $normal
    end

    # execution time of last command
    if test $CMD_DURATION -gt 1000
        set -l seconds (math --scale=0 "$CMD_DURATION / 1000 % 60")
        set -l minutes (math --scale=0 "$CMD_DURATION / (1000 * 60) % 60")
        set -l hours   (math --scale=0 "$CMD_DURATION / (1000 * 60 * 60)")
        echo -ns (set_color $cmd_duration_color) (printf ' (')
        test $hours   -gt 0; and echo -ns (printf "%dh " $hours)
        test $minutes -gt 0; and echo -ns (printf "%dm " $minutes)
        test $seconds -gt 0; and echo -ns (printf "%ds" $seconds)
        echo -ns (printf ')') $normal
    end

    # prompt suffix (1)
    echo -e ""
    echo -ns (set_color $arrow_color) \U279C $normal

    # error code
    if [ $local_status -ne 0 ]
        echo -ns (set_color red) " $local_status" $normal
    end

    # prompt suffix (2)
    echo -ns (set_color $sign_color) " \$ " $normal
end
