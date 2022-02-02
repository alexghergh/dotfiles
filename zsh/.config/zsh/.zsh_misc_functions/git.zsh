##
## Git related functionality
##

## current git branch
##
git_current_branch() {
    local ref
    ref=$(git symbolic-ref --quiet HEAD 2> /dev/null)
    local ret=$?
    if [[ $ret != 0 ]]; then
        [[ $ret == 128 ]] && return # no git repo
        ref=$(git rev-parse --short HEAD 2> /dev/null) || return
    fi
    echo "(${ref#refs/heads/})"
}
