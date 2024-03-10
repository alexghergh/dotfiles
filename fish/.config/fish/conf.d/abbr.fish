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

# discourage 'cd' use
abbr --add cd echo \
    \""Just don't use this, huh? (prefer simply - or .. or dir name)\""\; cd

# git stuff
abbr --add ga       git add
abbr --add gs       git status
abbr --add gco      git checkout
abbr --add gcb      git checkout -b
abbr --add gc       git commit
abbr --add gca      git commit --amend
abbr --add gp       git push
abbr --add gl       git log
abbr --add gla      git log --oneline --graph --all
abbr --add gsw      git switch
abbr --add gpup     git push --set-upstream origin

# discourage xdg-specific stuff
abbr --add xdg-open "echo 'Please do not use xdg-open; instead use open. If you feel like using it anyway, try \"command xdg-open\".'"

# make sudo commands share the same init.vim config file as the regular user
abbr --add sudovim sudo -E vim

# get my ip
abbr --add myp curl http://ipecho.net/plain

# texlive alias for tlmgr; hack for Arch
abbr --add tlmgr /usr/share/texmf-dist/scripts/texlive/tlmgr.pl --usermode

# quick directory scan
function multilevel_tree
    echo tree -La (string match --regex '\d+' $argv[1])
end
abbr --add tla --regex '^tl(\d+)' --function multilevel_tree
