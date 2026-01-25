# conda setup

if not status is-interactive
    return
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/alex/miniconda3/bin/conda
    eval /home/alex/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/home/alex/miniconda3/etc/fish/conf.d/conda.fish"
        . "/home/alex/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/home/alex/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<
