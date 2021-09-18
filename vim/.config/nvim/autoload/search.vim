" TODO improve this solution, it's just a nasty hack at the moment

" automatically set highlight off on cursor movement
noremap <silent> <Plug>(StopHL) <Cmd>nohlsearch<CR>
noremap! <expr> <Plug>(StopHL) execute('nohlsearch')

function search#HlSearch()
    let l:pos = match(getline('.'), @/, col('.') - 1) + 1
    if l:pos != col('.')
        call search#StopHL()
    endif
endfunction

function search#StopHL()
    if !v:hlsearch || mode() isnot 'n'
        return
    else
        call feedkeys("\<Plug>(StopHL)", "m")
    endif
endfunction
