## jabba (java version manager) setup

## TODO
if command -v jabba 1>/dev/null 2>&1; then
    export JABBA_HOME="$HOME/.jabba"
    [ -s "$JABBA_HOME/jabba.sh" ] && source "$JABBA_HOME/jabba.sh"
fi
