# Author: alexghergh
#
# For more information on `autoload', `typeset' or other shell builtins, see
# `man zshbuiltins', 'man zshzle', as well as the Zsh manual
#
# Table of contents for the current file:
#   1. environment variables and shell parameters
#   2. shell options
#   3. loaded stuff (prompts, completion, functions)
#   4. zstyles
#   5. aliases
#   6. widgets and keybinds
#   7. plugins
#


# set a zsh config path for the config of the shell
ZSH_CONFIG_PATH="${ZDOTDIR:-"$HOME/.config/zsh"}"


### environment variables and various exports

env_vars_file="$ZSH_CONFIG_PATH/.zsh_other/.zsh_env_vars"
[[ -f $env_vars_file ]] && source $env_vars_file
unset env_vars_file


### zsh options

options_file="$ZSH_CONFIG_PATH/.zsh_other/.zsh_options"
[[ -f $options_file ]] && source $options_file
unset options_file


### autoloaded stuff (prompts, completion, functions)

autoload_file="$ZSH_CONFIG_PATH/.zsh_other/.zsh_autoload"
[[ -f $autoload_file ]] && source $autoload_file
unset autoload_file


### zstyles

zstyle_file="$ZSH_CONFIG_PATH/.zsh_other/.zsh_zstyle"
[[ -f $zstyle_file ]] && source $zstyle_file
unset zstyle_file


### aliases

alias_file="$ZSH_CONFIG_PATH/.zsh_other/.zsh_aliases"
[[ -f $alias_file ]] && source $alias_file
unset alias_file


### zle keybinds (widgets)

zle_file="$ZSH_CONFIG_PATH/.zsh_other/.zsh_keybinds"
[[ -f $zle_file ]] && source $zle_file
unset zle_file


### plugins

for plugin_file in "$ZSH_CONFIG_PATH"/.zsh_plugins/*.zsh; do
    if [[ -f $plugin_file ]]; then
        source $plugin_file
    fi
done
unset plugin_file


# make sure tmux is always running
if [[ -z "$TMUX" ]]; then
    tmux attach
fi

unset ZSH_CONFIG_PATH
