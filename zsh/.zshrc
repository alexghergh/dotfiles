# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/alex/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="alexghergh"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    fancy-ctrl-z fzf safe-paste         # builtin plugins
    zsh-histdb                          # custom plugins added to `custom/plugins` directory
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# make sudo commands share the same init.vim config file as the regular user
alias sudovim="sudo -E vim"

setopt extendedglob     # allow extended globbing (zsh specific)
# setopt GLOBDOTS         # glob dotfiles when using globbing patterns
setopt HISTIGNOREDUPS   # ignore duplicate history entries
setopt HISTIGNORESPACE  # if the command begins with a space, it is not added to the history
setopt NOCLOBBER        # prevents an existing file from being overwritten if it exists;
                        #if you still want to overwrite it, type >! instead of just > 

export EDITOR=nvim
export VISUAL=nvim

# unbind the arrow keys and the backspace key
bindkey -s "^[[A" ""
bindkey -s "^[[B" ""
bindkey -s "^[[C" ""
bindkey -s "^[[D" ""
bindkey -s "\x7f" ""


# transpose 2 arguments in command line using Alt+z
# the normal transpose-words using Alt+t still works
word-style-transpose() {
    local WORDCHARS="*?_-.[]~=/&;!#$%^(){}<>"
    zle transpose-words
}
zle -N word-style-transpose
bindkey '^[z' word-style-transpose

if [ -f /etc/os-release ]; then
    os_id="$(sed '3q;d' /etc/os-release | sed 's/ID=//')"
fi

# if we're on ubuntu
if [ "$os_id" = 'ubuntu' ]; then
    # pyenv (python version manager) setup
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"

    if command -v pyenv 1>/dev/null 2>&1; then
        eval "$(pyenv init -)"
    fi
fi

# NVM lazy loading script
#
# NVM takes on average half of a second to load, which is more than whole prezto takes to load.
# This can be noticed when you open a new shell.
# To avoid this, we are creating placeholder function
# for nvm, node, and all the node packages previously installed in the system
# to only load nvm when it is needed.
#
# This code is based on the scripts:
# * https://www.reddit.com/r/node/comments/4tg5jg/lazy_load_nvm_for_faster_shell_start/d5ib9fs
# * http://broken-by.me/lazy-load-nvm/
# * https://github.com/creationix/nvm/issues/781#issuecomment-236350067
#

# NVM_DIR="$HOME/.nvm"

# # Skip adding binaries if there is no node version installed yet
# if [ -d $NVM_DIR/versions/node ]; then
#   NODE_GLOBALS=(`find $NVM_DIR/versions/node -maxdepth 3 \( -type l -o -type f \) -wholename '*/bin/*' | xargs -n1 basename | sort | uniq`)
# fi
# NODE_GLOBALS+=("nvm")

# load_nvm () {
#   # Unset placeholder functions
#   for cmd in "${NODE_GLOBALS[@]}"; do unset -f ${cmd} &>/dev/null; done

#   # Load NVM
#   [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

#   # (Optional) Set the version of node to use from ~/.nvmrc if available
#   nvm use 2> /dev/null 1>&2 || true

#   # Do not reload nvm again
#   export NVM_LOADED=1
# }

# for cmd in "${NODE_GLOBALS[@]}"; do
#   # Skip defining the function if the binary is already in the PATH
#   if ! which ${cmd} &>/dev/null; then
#     eval "${cmd}() { unset -f ${cmd} &>/dev/null; [ -z \${NVM_LOADED+x} ] && load_nvm; ${cmd} \$@; }"
#   fi
# done

# end of nvm setup --------------


# source jabba (java version manager)
export JABBA_HOME="$HOME/.jabba"
[ -s "$JABBA_HOME/jabba.sh" ] && source "$JABBA_HOME/jabba.sh"


# load zsh syntax highlighting
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 
fi

# load zsh autosuggestions
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi


# custom made history search using zsh_histdb
# this version checks for the command exit status
# see /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# the plugin was loaded above using `plugins` command
ZSH_AUTOSUGGEST_STRATEGY=(histdb)

# default fzf command
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# add LaTeX to path
export PATH="/usr/local/texlive/2020/bin/x86_64-linux:$PATH"
export PATH="/usr/bin/vendor_perl/:$PATH" # for biber
export MANPATH="/usr/local/texlive/2020/texmf-dist/doc/man:$MANPATH"
export INFOPATH="/usr/local/texlive/2020/texmf-dist/doc/info:$INFOPATH"

# set the xdg base directories specification (https://specifications.freedesktop.org/basedir-spec/latest/ar01s03.html)
# export XDG_CONFIG_HOME="$HOME/.config"
# export XDG_DATA_HOME="$HOME/.local/share"
# export XDG_CACHE_HOME="$HOME/.cache"
# export XDG_STATE_HOME="$HOME/.local/state"

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

alias gs="git status"
