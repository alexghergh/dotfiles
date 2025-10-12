# abbreviations

# only enable abbrs in interactive shells
if not status is-interactive
    return
end

# shortcuts
abbr --add --position anywhere desk     ~/Desktop/
abbr --add --position anywhere down     ~/Downloads/
abbr --add --position anywhere dots     ~/projects/dotfiles/
abbr --add --position anywhere research ~/projects/uni-research/
abbr --add --position anywhere proj     ~/projects/
abbr --add --position anywhere pack     ~/packages/
abbr --add --position anywhere tconf    ~/.config/tmux/
abbr --add --position anywhere vconf    ~/.config/nvim/
abbr --add --position anywhere fconf    ~/.config/fish/
abbr --add --position anywhere wconf    ~/.config/wezterm/

# system stuff
abbr --add                      h           history
abbr --add                      p           pwd
abbr --add                      mem         df -h
abbr --add                      dush        du -sh
abbr --add                      chx         chmod +x
abbr --add                      untar       tar -xvf
abbr --add                      unztar      tar -xzvf
abbr --add                      dotar       tar -cvf
abbr --add                      doztar      tar -czvf
abbr --add --position anywhere  sys         systemctl
abbr --add --position anywhere  stat        status
abbr --add                      susp        systemctl suspend
abbr --add                      httpserver  python -m http.server
abbr --add                      psa         'ps aux | grep'

# editor / tools
abbr --add v   nvim
abbr --add vi  nvim
abbr --add vim nvim
abbr --add py  python

# enables multicd:
#   .. -> cd ../
#   ... -> cd ../..
#   .... -> cd ../../..
# and so on
function multicd
    echo (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end
abbr --add --position anywhere cddotdot --regex '^\.\.+$' --function multicd

# shorthand for cd -
abbr --add cdminus --regex '^-$' cd -

# discourage 'cd' use
abbr --add cd echo \""Don't! (prefer zoxide's `c`)\""\; cd

# git stuff
abbr --add ga       git add
abbr --add gap      git add -p
abbr --add gs       git status
abbr --add gg       git status
abbr --add gco      git checkout
abbr --add gcb      git checkout -b
abbr --add gc       git commit
abbr --add gca      git commit --amend
abbr --add gp       git push
abbr --add gl       git log
abbr --add gla      git log --oneline --graph --all
abbr --add gsw      git switch
abbr --add gpup     git push --set-upstream origin
abbr --add gds      git diff --staged
abbr --add gdc      git diff --cached # (same as the above)
abbr --add gri      git rebase -i
abbr --add greco    git rebase --continue
abbr --add greab    git rebase --abort
abbr --add grs      git restore --staged
abbr --add gcl      git clone https://
abbr --add gcgh     git clone https://github.com/
abbr --add gcgl     git clone https://gitlab.com/

# discourage xdg-specific stuff
abbr --add xdg-open "echo 'Please do not use xdg-open; instead use open. If you feel like using it anyway, try \"command xdg-open\".'"

# make sudo commands share the same init.vim config file as the regular user
abbr --add sudov    sudo -E vim
abbr --add sudovim  sudo -E vim
abbr --add sudonvim sudo -E vim

# get my ip
abbr --add myp curl http://ipecho.net/plain
abbr --add myip curl http://ipecho.net/plain

# texlive alias for tlmgr; hack for Arch
abbr --add tlmgr /usr/share/texmf-dist/scripts/texlive/tlmgr.pl --usermode

# quick directory scan
function multilevel_tree
    echo tree -a -L (string match --regex '\d+' $argv[1])
end
abbr --add tla --regex '^tl(\d+)' --function multilevel_tree
