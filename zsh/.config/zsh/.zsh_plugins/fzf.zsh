# don't run in non-interactive shells
[[ -o interactive ]] || return 0

# default fzf command
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

if [ -f /etc/os-release ]; then
    os_id="$(sed '3q;d' /etc/os-release | sed 's/ID=//')"
fi

# if we're on ubuntu
if [ "$os_id" = 'ubuntu' ]; then

    key_bindings_file="/usr/share/doc/fzf/examples/key-bindings.zsh"
    completions_file="/usr/share/doc/fzf/examples/completion.zsh"

# if we're on arch linux
elif [ "$os_id" = 'arch' ]; then

    key_bindings_file="/usr/share/fzf/key-bindings.zsh"
    completions_file="/usr/share/fzf/completion.zsh"

fi

if [[ -f "$key_bindings_file" ]]; then
    source "$key_bindings_file"
fi

if [[ -f "$completions_file" ]]; then
    source "$completions_file"
fi

unset key_bindings_file
unset completions_file
