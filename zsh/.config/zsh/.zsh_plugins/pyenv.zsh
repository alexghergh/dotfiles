return 0

## pyenv (python version manager) setup

if command -v pyenv 1>/dev/null 2>&1; then

    if [ -f /etc/os-release ]; then
        os_id="$(sed '3q;d' /etc/os-release | sed 's/ID=//')"
    fi

    # if we're on ubuntu
    if [ "$os_id" = 'ubuntu' ]; then
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
    fi

    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi
