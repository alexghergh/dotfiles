function fish_prompt
    set -l local_status $status # needs to be first thing
    set -l normal (set_color normal)

    # jobs
    jobs -q
    and set_color $fish_color_jobs_present
    or set_color $fish_color_jobs_absent
    echo -ns "(" (count (string split "\n" (jobs -p))) ") " $normal

    # username and host
    echo -ns (prompt_login) $normal

    # path
    echo -ns ":" (set_color $fish_color_pwd) (prompt_pwd) $normal

    # vcs info
    echo -ns (fish_vcs_prompt) $normal

    # execution time of last command
    if test $CMD_DURATION -gt 1000
        set -l seconds (math --scale=0 "$CMD_DURATION / 1000 % 60")
        set -l minutes (math --scale=0 "$CMD_DURATION / (1000 * 60) % 60")
        set -l hours   (math --scale=0 "$CMD_DURATION / (1000 * 60 * 60)")
        echo -ns (set_color $fish_color_cmd_duration) (printf ' (')
        test $hours   -gt 0; and echo -ns (printf "%dh " $hours)
        test $minutes -gt 0; and echo -ns (printf "%dm " $minutes)
        test $seconds -gt 0; and echo -ns (printf "%ds" $seconds)
        echo -ns (printf ')') $normal
    end

    # prompt suffix (1)
    echo -e ""
    echo -ns (set_color $fish_color_suffix) \U279C

    # error code
    if [ $local_status -ne 0 ]
        echo -ns (set_color red) " $local_status"
    end

    # prompt suffix (2)
    echo -ns (set_color $fish_color_suffix) " \$ " $normal
end
