# Author: alexghergh
#
# For more information on `autoload', `typeset' or other shell builtins, see
# `man zshbuiltins', 'man zshzle'






# -U stands for unique

# remove duplicates in both PATH and path
# they are both synced anyway
typeset -U PATH path

# remove duplicates in both FPATH and fpath
# they are both synced anyway
typeset -U FPATH fpath






### environment variables

# look for custom defined functions in the directory below and automatically
# load them
fpath=( "$HOME/.config/zsh/.zsh_functions" $fpath )
autoload -Uz ${fpath[1]}/*(:t)

# look for custom defined prompts and load them
fpath=( "$HOME/.config/zsh/.zsh_prompts" $fpath )


### autoload

# -U suppress alias expansion when function is loaded
# -z zsh-style
#
# load completion
autoload -Uz compinit
compinit

# load the prompt theme system
autoload -Uz promptinit
promptinit

# set the custom prompt theme
prompt alex


# by default, run-help is aliased to man
# to actually get useful help for shell builtins, load the run-help module
autoload -Uz run-help
(( ${+aliases[run-help]} )) && unalias run-help
alias help=run-help
# when running "run-help git commit" for example,
# open man git-commit instead of man git
autoload -Uz run-help-git run-help-ip run-help-openssl run-help-p4 run-help-sudo


### setopt

# complete options to command aliases
setopt complete_aliases

# allow extended globbing (zsh specific, see https://zsh.sourceforge.io/Intro/intro_2.html#SEC2 and
# https://zsh.sourceforge.io/Guide/zshguide05.html#l139)
setopt extended_glob

# some better directory history options
# use with cd -<dir number listed with dirl> or ls =<dir number listed with dirl>
#
# use a directory history of 8 directories
DIRSTACKSIZE=8

# use cd like a pushd (for different reasons not listed on the official page, you cannot simply
# set cd=pushd)
setopt auto_pushd

# make cd -<dir number> work as expected
setopt pushd_minus

# don't print the directory stack each time we do a cd
setopt pushd_silent

# add home to directory stack when doing `cd' alone
setopt pushd_to_home

# ignore the duplicate directory entries
setopt pushd_ignore_dups

# alias for easy directory stack listing
alias dirl="dirs -v"

# this makes it so that `foo/$vars' expands to `foo/$1 foo/$2...' instead of `foo/$1 $2...'
setopt rc_expand_param

# glob dotfiles when using globbing patterns
setopt glob_dots

# prevents an existing file from being overwritten if it exists;
# if you still want to overwrite it, type >| instead of just >
# !! don't use >!, as the `!' might be a history expansion
setopt no_clobber

# create a file if it does not exist when appending with `>> file'
setopt append_create

# output to multiple files at the same time, similar to `tee'
# also causes filename expansion to happen inside redirections
setopt multios

# monitor the foreground and background jobs and notify about them
setopt monitor

# notify immediately on background jobs, don't wait until the next prompt
setopt notify

# allow comments in the middle of a command
setopt interactive_comments

# when executing a function that changes some setopts, they will be
# put back when the function finishes
setopt local_options

# when executing a function that needs to, say, ignore some traps
# this helps with only changing the traps inside the function
# (see https://zsh.sourceforge.io/Guide/zshguide02.html, search for LOCAL_TRAPS)
setopt local_traps

# ignore duplicate history entries when doing them one after the other
setopt hist_ignore_dups

# if the command begins with a space, it is not added to the history
setopt hist_ignore_space

# when using bang-history (i.e. !!) with different modifiers, show a prompt for the
# command execution with the substions in place (easy to see if the command
# is actually what you want), before actually pressing enter
# (see https://zsh.sourceforge.io/Guide/zshguide02.html, search for bang-history)
setopt hist_verify

# append to the history file instead of overwriting it
setopt append_history

# don't append a command to the history file (this NEEDS to be set off because
# of the option below)
setopt no_inc_append_history

# share history between shells; also appends history commands (as if
# `incappendhistory' was set, see above)
# by default, all the shells get the same history file (global)
# but there are additional binds down below to only navigate LOCAL
# history (local to a particular shell; only the commands issued in that
# shell, for more info see
# https://zsh.sourceforge.io/Doc/Release/Options.html#index-SHARE_005fHISTORY)
setopt share_history

# add more information to the history file, like date and time elapsed
setopt extended_history

# automatically cd into a directory if it exists just by typing the dir name
setopt auto_cd

# don't beep when completion can't find a match
setopt no_beep

# one completion item is always inserted, then cycle through by using TAB
setopt menu_complete

# automatically remove slash after directory name completion
# (see https://zsh.sourceforge.io/Guide/zshguide06.html#l150)
setopt auto_remove_slash

# when typing e.g. `Maefile' and going back to complete, correctly complete
# `Makefile' instead of `Maefile*'
setopt complete_in_word

# always move cursor to end of completion, even if the completion took place in
# the middle of the word
setopt always_to_end

# when completing items, list `/' for directories, `*' for executables, `@' for
# links etc. (similar to ls -F)
# (see https://zsh.sourceforge.io/Guide/zshguide06.html#l151)
setopt list_types

# allow parameter expansion, arithmetic expansion and command substitution to
# be expanded inside the prompt string
setopt prompt_subst

# allow history expansion with `!' to happen inside the prompt string
# setopt prompt_bang

# allow certain escape sequences inside the prompt string
setopt prompt_percent


### zle options and widgets

# emacs style keybindings
bindkey -e

# unbind the arrow keys and the backspace key
bindkey -s "^[[A" ""
bindkey -s "^[[B" ""
bindkey -s "^[[C" ""
bindkey -s "^[[D" ""
bindkey -s "\x7f" ""

# prefix searching
#
# search for identic history up from the beginning of the line up to the cursor
# position
# !! `^x^n' overwrites `infer-next-history' (for now not needed, maybe in the
# future, for what it does, see https://zsh.sourceforge.io/Guide/zshguide04.html,
# search for `infer-next-history')
bindkey '^x^p' history-beginning-search-backward
bindkey '^x^n' history-beginning-search-forward

# copy the last shell argument
# useful for cases when you want to `mv' something like a large directory
# you only have to write the path once, then copy it and then simply change
# the last word
copy-prev-big-word() {
    local WORDCHARS="*?_-.[]~=/&;!#$%^(){}<>"
    zle copy-prev-word
}
zle -N copy-prev-big-word
bindkey '^[e' copy-prev-big-word

# transpose 2 arguments in command line using Alt+z; the normal transpose-words
# using Alt+t still works; this has the added benefit the cursor doesn't move,
# though sometimes it might be an inconvenience
word-style-transpose() {
    emulate -L zsh
    local cursor_pos
    cursor_pos=$CURSOR

    local WORDCHARS="*?_-.[]~=/&;!#$%^(){}<>"
    zle transpose-words

    CURSOR=$cursor_pos
}
zle -N word-style-transpose
bindkey '^[z' word-style-transpose

# replace the default push-line by push-line-or-edit
# has the same effect as normal <esc>-q when in the PS1 prompt, but has
# a different effect in PS2; namely, it brings the multiline command on the
# prompt, so you can scroll to lines above (this wasn't possible
# otherwise)
bindkey '^[q' push-line-or-edit

# only navigate the local history (local to a shell, see `sharehistory' above)
# (see https://superuser.com/questions/446594/separate-up-arrow-lookback-for-local-and-global-zsh-history)
up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history
bindkey "^x^h" up-line-or-local-history

# only navigate the local history (local to a shell, see `sharehistory' above)
# (see https://superuser.com/questions/446594/separate-up-arrow-lookback-for-local-and-global-zsh-history)
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history
bindkey "^x^g" down-line-or-local-history


### zstyles

# highlight the entries in the completion menu
zstyle ':completion:*' menu select=1

# max number of spelling errors
zstyle ':completion:*' max-errors 2

# if you start a command with sudo, the completions will try
# to also complete commands in the super user context
# (commented due to the fact that this runs scripts with sudo permissions)
# zstyle ':completion::complete:*' gain-privileges 1

# when installing new packages, automatically rehash to get
# completion for them
# (commented due to the performance penalty involved)
# zstyle ':completion:*' rehash true


### various exports (TODO probably move these to ~/.zshenv)

# some basic setup
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=firefox
export PAGER=less

# set the xdg base directories specification
# (https://specifications.freedesktop.org/basedir-spec/latest/ar01s03.html)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# set the word chars that SHOULD also be considered as part of a word
# the characters that are not in here from the default WORDCHARS are '/', '.'
# and '-'
export WORDCHARS="*?_[]~=&;!#$%^(){}<>"

# increase history size for both session history and file
# history, we're living in 2021
export HISTSIZE=50000
export SAVEHIST=50000
# history file
export HISTFILE="$HOME/.zsh_history"






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

# source $ZSH/oh-my-zsh.sh

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
alias ls="ls --color=tty"
alias l="ls -lah"
alias la="ls -lh"


if [ -f /etc/os-release ]; then
    os_id="$(sed '3q;d' /etc/os-release | sed 's/ID=//')"
fi

# if we're on ubuntu
if [ "$os_id" = 'ubuntu' ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
fi

# pyenv (python version manager) setup
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
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


## custom made history search using zsh_histdb
## this version checks for the command exit status
## see /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
## the plugin was loaded above using `plugins` command
#ZSH_AUTOSUGGEST_STRATEGY=(histdb)

# default fzf command
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# add LaTeX to path
# export PATH="/usr/local/texlive/2020/bin/x86_64-linux:$PATH"
# export PATH="/usr/bin/vendor_perl/:$PATH" # for biber
# export MANPATH="/usr/local/texlive/2020/texmf-dist/doc/man:$MANPATH"
# export INFOPATH="/usr/local/texlive/2020/texmf-dist/doc/info:$INFOPATH"
alias tlmgr='/usr/share/texmf-dist/scripts/texlive/tlmgr.pl --usermode'

if [[ -z "$XDG_DATA_DIRS" ]]; then
    export XDG_DATA_DIRS="/usr/local/share/:/usr/share/"
fi

if [[ -z "$XDG_CONFIG_DIRS" ]]; then
    export XDG_CONFIG_DIRS="/etc/xdg"
fi

# make sure tmux is always running
if [[ -z "$TMUX" ]]; then
    tmux attach
fi

alias gs="git status"
alias myip="curl http://ipecho.net/plain; echo"
