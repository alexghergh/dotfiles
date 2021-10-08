typeset -U PATH path
# Since .zshenv is always sourced, it often contains exported variables that should be available to other programs. For example, $PATH, $EDITOR, and $PAGER are often set in .zshenv. Also, you can set $ZDOTDIR in .zshenv to specify an alternative location for the rest of your zsh configuration.
#
# .zshenv is read by programs in non-login, non-interactive shells (i.e. when a program runs another program in a shell, for example)
