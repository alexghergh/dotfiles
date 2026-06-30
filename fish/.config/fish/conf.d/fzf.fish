# fzf setup; fzf has native integration with fish
# see https://junegunn.github.io/fzf/shell-integration/
#
# keybinds:
#   Ctrl-R - fuzzy search command history (Ctrl-Y copies the command)
#   Ctrl-T - fuzzy complete a command (insert a file / dir path at the cursor)
#   Alt-C  - fuzzy cd into a subdirectory
#   Ctrl-/ - toggle / cycle the preview window

# only enable keybinds in interactive shells
if not status is-interactive
    return
end

# if fzf doesn't exist, warn and skip setup
if not type -q fzf
    echo "warning: fzf not installed" >&2
    return
end

# global look + behavior (fzf splits *_OPTS on whitespace, newlines included)
set -gx FZF_DEFAULT_OPTS "
    --height=60% --layout=reverse --info=inline-right
    --bind=ctrl-/:toggle-preview
"

# use fd for file/dir walking when available (respects .gitignore, skips .git)
if type -q fd
    set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
    set -gx FZF_CTRL_T_COMMAND "fd --hidden --follow --exclude .git"
    set -gx FZF_ALT_C_COMMAND "fd --type d --hidden --follow --exclude .git"
end

# preview commands, with fallbacks if eza/bat are missing
set -l preview_file "bat -n --color=always --line-range :500 {} 2>/dev/null || cat {}"
set -l preview_dir "eza --tree --level=2 --color=always {} 2>/dev/null || ls -1 {}"

# Ctrl-T: tree-preview dirs, syntax-highlight files
set -gx FZF_CTRL_T_OPTS "
    --walker-skip .git,node_modules,target
    --preview 'test -d {} && ($preview_dir) || ($preview_file)'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'
"

# Alt-C: preview the target directory tree
set -gx FZF_ALT_C_OPTS "
    --walker-skip .git,node_modules,target
    --preview '$preview_dir'
"

# Ctrl-R: preview the full command; Ctrl-Y copies it to the clipboard
set -l clip
if type -q wl-copy
    set clip wl-copy
else if type -q xsel
    set clip "xsel -b"
else if type -q xclip
    set clip "xclip -selection clipboard"
end

set -l ctrlr "
    --preview 'echo {}' --preview-window up:3:hidden:wrap
    --bind 'ctrl-/:toggle-preview'
    --color header:italic
"
if test -n "$clip"
    set ctrlr "$ctrlr
        --bind 'ctrl-y:execute-silent(echo -n {2..} | $clip)+abort'
        --header 'ctrl-y: copy command, ctrl-/: toggle preview'"
else
    set ctrlr "$ctrlr --header 'ctrl-/: toggle preview'"
end
set -gx FZF_CTRL_R_OPTS "$ctrlr"

# load fzf's built-in fish key bindings
fzf --fish | source
