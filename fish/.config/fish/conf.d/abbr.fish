# abbreviations

# only enable abbrs in interactive shells
if not status is-interactive
    return
end

# enables multicd:
#   .. -> cd ../
#   ... -> cd ../..
#   .... -> cd ../../..
# and so on
function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add cddotdot --regex '^\.\.+$' --function multicd

# shorthand for cd -
abbr --add cdminus --regex '^-$' cd -

# TODO fex these
# discourage use of 'cd -' and 'cd ..' in favor of the above
abbr --add cdwhy --position anywhere --regex '^cd -$' echo 'Just use -'
abbr --add cddie --position anywhere --regex '^cd \.\.' 'haha lol'

# TODO make abbreviations only work in interactive shells (that makes sense, right)

# git stuff
abbr --add ga       git add
abbr --add gs       git status
abbr --add gco      git checkout
abbr --add gc       git commit
abbr --add gca      git commit --amend
abbr --add gp       git push
abbr --add gl       git log
abbr --add gla      git log --oneline --graph --all
# TODO add a function to remind me to use these if they exist

# discourage xdg-specific stuff
abbr --add xdg-open "echo 'Please do not use xdg-open; instead use open.'"

# make sudo commands share the same init.vim config file as the regular user
abbr --add sudovim sudo -E vim
# TODO make alt+s with vim automatically insert sudo -E instead of just sudo

# get my ip
abbr --add myp curl http://ipecho.net/plain

# texlive alias for tlmgr; hack for Arch
abbr --add tlmgr /usr/share/texmf-dist/scripts/texlive/tlmgr.pl --usermode

# quick directory scan
abbr --add tla tree -La
# TODO potentially use a "tl<number>" regex to match this easier?
