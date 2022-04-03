# Author: alexghergh
#
# For more information on `autoload', `typeset' or other shell builtins, see
# `man zshbuiltins', 'man zshzle'


###

# -U stands for unique

# remove duplicates in both PATH and path
# they are both synced anyway
typeset -U PATH path

# remove duplicates in both FPATH and fpath
# they are both synced anyway
typeset -U FPATH fpath


# set a zsh config path
ZSH_CONFIG_PATH=${ZSH_CONFIG_PATH:-"$HOME/.config/zsh"}


### zsh functions and prompts

# look for custom defined functions in the directory below and automatically
# load them
fpath=( "$ZSH_CONFIG_PATH/.zsh_functions" $fpath )
autoload -Uz ${fpath[1]}/*(:t)

# look for custom defined prompts and load them
fpath=( "$ZSH_CONFIG_PATH/.zsh_prompts" $fpath )

# load other custom defined functions that are not autoloaded
for config_file in "$ZSH_CONFIG_PATH"/.zsh_misc_functions/*.zsh; do
    [[ -f "$config_file" ]] && source "$config_file"
done
unset config_file


### environment variables and various exports

env_vars_file="$ZSH_CONFIG_PATH/.zsh_other/.zsh_env_vars"
[[ -f $env_vars_file ]] && source $env_vars_file
unset env_vars_file


### autoloaded stuff (completion system, prompts etc.)

autoload_file="$ZSH_CONFIG_PATH/.zsh_other/.zsh_autoload"
[[ -f $autoload_file ]] && source $autoload_file
unset autoload_file


### set zsh options

options_file="$ZSH_CONFIG_PATH/.zsh_other/.zsh_options"
[[ -f $options_file ]] && source $options_file
unset options_file


### zle keybinds (widgets)

zle_file="$ZSH_CONFIG_PATH/.zsh_other/.zsh_keybinds"
[[ -f $zle_file ]] && source $zle_file
unset zle_file


### zstyles

zstyle_file="$ZSH_CONFIG_PATH/.zsh_other/.zsh_zstyle"
[[ -f $zstyle_file ]] && source $zstyle_file
unset zstyle_file


### aliases

alias_file="$ZSH_CONFIG_PATH/.zsh_other/.zsh_aliases"
[[ -f $alias_file ]] && source $alias_file
unset alias_file


###



# load zsh syntax highlighting
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 
fi

# load zsh autosuggestions
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi


## custom made history search using zsh_histdb
## this version checks for the command exit status
## see /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
## the plugin was loaded above using `plugins` command
#ZSH_AUTOSUGGEST_STRATEGY=(histdb)

# if [[ -z "$XDG_DATA_DIRS" ]]; then
#     export XDG_DATA_DIRS="/usr/local/share/:/usr/share/"
# fi

# if [[ -z "$XDG_CONFIG_DIRS" ]]; then
#     export XDG_CONFIG_DIRS="/etc/xdg"
# fi

# make sure tmux is always running
if [[ -z "$TMUX" ]]; then
    tmux attach
fi


# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#plugins=(
#    fancy-ctrl-z fzf safe-paste         # builtin plugins
#    zsh-histdb                          # custom plugins added to `custom/plugins` directory
#)
