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

# navigate directory history (same as cdh) with left and right arrow keys, if
# command line is empty, otherwise just move a character
function __prevd-or-backward-char
    # get initial cursor position
    set -l initial_cursor_position (commandline --cursor)

    # if not 0, we can safely assume command line is not empty
    if [ $initial_cursor_position -ne 0 ]
        commandline -f backward-char

    # if 0, we need to check if there's text in the command line
    else if [ $initial_cursor_position -eq 0 ]
        # try to move the cursor and re-read the position
        commandline --cursor 1
        set -l cursor_position (commandline --cursor)

        if [ $cursor_position -eq 0 ]
            prevd
            commandline -f repaint
        else
            commandline --cursor $cursor_position
            commandline -f backward-char
        end
    end
end
bind \e\[D __prevd-or-backward-char # left arrow

function __nextd-or-forward-char
    # get initial cursor position
    set -l initial_cursor_position (commandline --cursor)

    # if not 0, we can safely assume command line is not empty
    if [ $initial_cursor_position -ne 0 ]
        commandline -f forward-char

    # if 0, we need to check if there's text in the command line
    else if [ $initial_cursor_position -eq 0 ]
        # try to move the cursor and re-read the position
        commandline --cursor 1
        set -l cursor_position (commandline --cursor)

        if [ $cursor_position -eq 0 ]
            nextd
            commandline -f repaint
        else
            commandline --cursor $cursor_position
            commandline -f forward-char
        end
    end
end
bind \e\[C __nextd-or-forward-char # right arrow
