"-- Plugins --------------------------------------------------------------------

exec "luafile " . stdpath("config") . "/lua/alexghergh/plugins.lua"


"-- Settings -------------------------------------------------------------------

exec "luafile " . stdpath("config") . "/lua/alexghergh/settings.lua"


"-- Keymappings ----------------------------------------------------------------

exec "luafile " . stdpath("config") . "/lua/alexghergh/keymappings.lua"


exec "luafile " . stdpath("config") . "/lua/alexghergh/globals.lua"

"-- Other ----------------------------------------------------------------------

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

    " better commenting in c and cpp
    autocmd FileType c,cpp setlocal comments-=:// comments+=f://

    " text width for ceratin filetypes
    autocmd FileType c,cpp,markdown setlocal textwidth=80

augroup END

" clean extra spaces on some filetypes
augroup _user_aug
    autocmd BufWritePre *.zsh,*.vim,*.c,*.txt,*.js,*.py,*.wiki,*.sh,*.coffee,*.java,*.lua :call functions#CleanExtraSpaces()
augroup END

" stop highlighting on cursor movement
augroup SearchHighlight
    autocmd!
    autocmd CursorMoved * call search#HlSearch()
    autocmd InsertEnter * call search#StopHL()
augroup end

" show color
nnoremap <Leader>sc <Cmd>call functions#DisplayColorUnderCursorAsBackground()<CR>


" vim: set tw=0 fo-=r
