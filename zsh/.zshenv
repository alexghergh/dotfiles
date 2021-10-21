# Since .zshenv is always sourced, it often contains exported variables that should be available to other programs. For example, $PATH, $EDITOR, and $PAGER are often set in .zshenv. Also, you can set $ZDOTDIR in .zshenv to specify an alternative location for the rest of your zsh configuration.

# -U stands for unique

# remove duplicates in both PATH and path
# they are both synced anyway
typeset -U PATH path

# remove duplicates in both FPATH and fpath
# they are both synced anyway
typeset -U FPATH fpath
