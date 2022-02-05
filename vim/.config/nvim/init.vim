" Author: alexghergh
"
" These are some of the Neovim config files that I use.

" <Space> as leader key
" Good to set this early
let g:mapleader = ' '
let g:maplocalleader = ' '

"-- Plugins

runtime lua/alexghergh/plugins.lua

"-- Keymappings

runtime lua/alexghergh/keymappings.lua

"-- Some useful globals

runtime lua/alexghergh/globals.lua

"-- Other

filetype plugin indent on

" create an empty augroup for the user autocommands
augroup _user_aug
    autocmd!

    " highlight text on yank
    autocmd TextYankPost * lua vim.highlight.on_yank { timeout = 500 }

    " when vim gets resized (due to tmux zooming and unzooming for example),
    " make the windows equal
    autocmd VimResized * wincmd =

    " open file to last known position
    autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif

    " clean extra spaces on some filetypes
    autocmd BufWritePre *.zsh,*.vim,*.c,*.cpp,*.txt,*.js,*.py,*.wiki,*.sh,*.coffee,*.java,*.lua :call functions#CleanExtraSpaces()
augroup END

" stop highlighting on cursor movement
augroup SearchHighlight
    autocmd!
    autocmd CursorMoved * call search#HlSearch()
    autocmd InsertEnter * call search#StopHL()
augroup end


" vim: set tw=0 fo-=r
