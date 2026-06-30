# zoxide setup (smarter cd command)
# database saved in ~/.local/share/zoxide

# only enable keybinds in interactive shells
if not status is-interactive
    return
end

# if zoxide doesn't exist, warn and skip setup
if type -q zoxide
    zoxide init --cmd c fish | source
else
    echo "warning: zoxide not installed; smarter cd disabled" >&2
end
