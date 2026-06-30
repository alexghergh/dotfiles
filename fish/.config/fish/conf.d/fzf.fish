# fzf setup; fzf has native integration with fish
# see https://junegunn.github.io/fzf/shell-integration/
# 
# default keybinds:
#   Ctrl-R - fuzzy search command history
#   Ctrl-T - fuzzy paste a file / dir path at the cursor
#   Alt-C  - fuzzy cd into a subdirectory

# only enable keybinds in interactive shells
if not status is-interactive
    return
end

# load fzf's built-in fish key bindings
if type -q fzf
    fzf --fish | source
else
    echo "warning: fzf not installed; fuzzy history (Ctrl-R), files (Ctrl-T) and cd (Alt-C) disabled" >&2
end
