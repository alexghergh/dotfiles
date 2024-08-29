# zoxide setup

# only enable keybinds in interactive shells
if not status is-interactive
    return
end

zoxide init --cmd c fish | source
