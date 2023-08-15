function fish_prompt

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
    if test $CMD_DURATION -gt 500
        echo -ns (set_color $fish_color_cmd_duration)
        echo -ns (printf " (%.1fs)" (math $CMD_DURATION / 1000)) $normal
    end

    # prompt suffix
    echo -e ""
    echo -ns (set_color $fish_color_suffix) \U279C " \$ " $normal
end
