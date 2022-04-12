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

# clone antidote if necessary
[[ -d "$ZSH_CONFIG_PATH"/.antidote ]] \
    || git clone --depth=1 https://github.com/mattmc3/antidote.git "$ZSH_CONFIG_PATH"/.antidote

# source antidote
source "$ZSH_CONFIG_PATH"/.antidote/antidote.zsh

# create the plugin file if it doesn't exist
[[ -f "$ZSH_CONFIG_PATH"/.zsh_plugins.txt ]] || touch "$ZSH_CONFIG_PATH"/.zsh_plugins.txt

# generate a static plugin file if necessary
if [[ ! "$ZSH_CONFIG_PATH"/.zsh_plugins.zsh -nt "$ZSH_CONFIG_PATH"/.zsh_plugins.txt ]]; then
    antidote bundle <"$ZSH_CONFIG_PATH"/.zsh_plugins.txt >|"$ZSH_CONFIG_PATH"/.zsh_plugins.zsh
fi

# for antidote commands (see antidote --help)
autoload -Uz "$ZSH_CONFIG_PATH"/.antidote/functions/antidote

# source static plugins file
source "$ZSH_CONFIG_PATH"/.zsh_plugins.zsh


# make sure tmux is always running
if [[ -z "$TMUX" ]]; then
    tmux attach
fi

unset ZSH_CONFIG_PATH
