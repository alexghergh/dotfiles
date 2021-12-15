## .zprofile is basically the same as .zlogin except that it's sourced before .zshrc while .zlogin is sourced after .zshrc. According to the zsh documentation, ".zprofile is meant as an alternative to .zlogin for ksh fans; the two are not intended to be used together, although this could certainly be done if desired."
#
## Login shell custom commands and options
## This runs once when the system starts (will be read when starting as a login shell)
## To reload: "exec zsh --login"
#
## Neovim > Vim
##export EDITOR=nvim
##export VISUAL=nvim
##export VIM=nvim
#
## unbind the arrow keys and the backspace key
## !!! this is terminal specific !!!
##bindkey -s "^[[A" ""
##bindkey -s "^[[B" ""
##bindkey -s "^[[C" ""
##bindkey -s "^[[D" ""
##bindkey -s "\x7f" ""
#
## transpose 2 arguments in command line using Alt+z
## the normal transpose-words using Alt+t still works
##word-style-transpose() {
##    local WORDCHARS="*?_-.[]~=/&;!#$%^(){}<>"
##    zle transpose-words
##}
##zle -N word-style-transpose
##bindkey '^[z' word-style-transpose
#
### pyenv (python version manager) setup
##if command -v pyenv 1>/dev/null 2>&1; then
##    #export PYENV_ROOT="$HOME/.pyenv"
##    #export PATH="$PYENV_ROOT/bin:$PATH"
##    eval "$(pyenv init --path)"
##    eval "$(pyenv init -)"
##fi
##
### jabba (java version manager) setup
##if command -v jabba 1>/dev/null 2>&1; then
##    export JABBA_HOME="$HOME/.jabba"
##    [ -s "$JABBA_HOME/jabba.sh" ] && source "$JABBA_HOME/jabba.sh"
##fi
#
### load zsh syntax highlighting
##if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
##    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 
##fi
##
### load zsh autosuggestions
##if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
##    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
##fi
#
## default fzf command
#export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
#export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
