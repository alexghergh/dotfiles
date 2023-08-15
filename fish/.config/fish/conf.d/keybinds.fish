# keybinds

# only enable keybinds in interactive shells
if not status is-interactive
    return
end

# duplicate last word in the commandline
function __dup_last_word
    set -l cmd (string split ' ' (string trim (commandline)))
    commandline --insert $cmd[-1]
end
bind \co\cd __dup_last_word

# transpose the 2 previous arguments to the cursor if on a word
# if the cursor is on an empty space, transpose the adjacent 2 arguments
bind \co\ct 'transpose-words'

# cycle through long/short path displays
# see https://fishshell.com/docs/current/cmds/prompt_pwd.html)
function __cycle_prompt_display
    test $fish_prompt_pwd_full_dirs -eq 1
    and set fish_prompt_pwd_full_dirs 999
    or set fish_prompt_pwd_full_dirs 1
    commandline -f repaint
end
bind \co\cr __cycle_prompt_display
