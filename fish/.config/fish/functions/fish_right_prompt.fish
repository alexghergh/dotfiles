function fish_right_prompt
    # save the status locally, since set_color changes the $status itself
    set -l local_status $status

    if [ $local_status -eq 0 ]
        echo -n (set_color green) \U2713 " "
    else
        echo -n (set_color red) $local_status " "
    end
end
