function fish_prompt
    set -l local_status $status # needs to be first thing

    # some colors (borrowed from fish's colors to match the scheme)
    set -l normal (set_color normal)
    set -l end_of_command $fish_color_error
    set -l jobs_present_color $fish_color_error
    set -l jobs_absent_color $fish_color_command
    set -l username_color $fish_color_param
    set -l hostname_color $fish_color_keyword
    set -l cwd_color $fish_color_redirection
    set -l vcs_color $fish_color_quote
    set -l arrow_color $fish_color_autosuggestion
    set -l sign_color $fish_color_autosuggestion
    set -l cmd_duration_color $fish_color_comment

    # separate from previous command output
    echo -ns (set_color $end_of_command) "\n--------eoc--------\n"

    # jobs
    jobs -q
    and set_color $jobs_present_color
    or set_color $jobs_absent_color
    echo -ns "(" (count (string split "\n" (jobs -p))) ") " $normal

    # username and host
    set -l color_host
    echo -ns (set_color $username_color) "$USER" $normal @ (set_color $hostname_color) (prompt_hostname) $normal

    # path
    echo -ns ":" (set_color $cwd_color) (prompt_pwd) $normal

    # vcs info
    echo -ns (set_color $vcs_color) (fish_vcs_prompt) $normal

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
