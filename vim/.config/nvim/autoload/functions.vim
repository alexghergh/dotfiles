" display the color under cursor using the background of the current window
" the color has to be in the form '#RRGGBB'
" TODO move this to lua
function functions#DisplayColorUnderCursorAsBackground()

    " get the current highlighting used for the background
    " TODO use a variable instead of a register
    redir @a
    silent highlight Normal
    redir END

    " eliminate the extra noise
    let l:saved_bg = substitute(@a, '^.*guibg=\(.*\).*$', '\1', '')

    " get the word under the cursor
    " TODO check that this is actually a hex rgb number
    " TODO treat the case where the word is empty
    let l:new_bg = expand("<cword>")

    " set the background with the word under the cursor
    execute 'highlight Normal guibg=' .. l:new_bg

    " wait 2 seconds
    " TODO move to a toggle or, even better, another small preview window
    " instead of swapping the background color
    sleep 2

    " execute the command we saved (aka restore background)
    execute 'highlight Normal guibg=' .. l:saved_bg

endfunction
