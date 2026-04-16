# atuin setup (enhanced history search)
# database saved in ~/.

# only enable keybinds in interactive shells
if not status is-interactive
    return
end

# if atuin doesn't exist, skip setup
if type -q atuin
    atuin init fish | source

    # install codex and claude code hooks; these will also add commands ran by
    # these agents to the searchable history (requires atuin >= 18.13)
    if atuin hook 2>/dev/null
        atuin hook install codex
        atuin hook install claude-code
    end
end
