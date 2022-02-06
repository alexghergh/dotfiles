-- due to how the column offset is calculated for the
-- hunk preview, a line needed to be commented in the
-- source code so the hunk preview is aligned to the
-- rest of the text
-- file changed: vim-signify/autoload/sy/util.vim - L201

-- show hunk diff preview window
vim.api.nvim_set_keymap('n', "<Leader>hs", "<Cmd>SignifyHunkDiff<CR>", { noremap = true })

-- hunk undo (similar to git checkout)
vim.api.nvim_set_keymap('n', "<Leader>hu", "<Cmd>SignifyHunkUndo<CR>", { noremap = true })

-- go to next/previous hunks
vim.api.nvim_set_keymap('n', "]h", "<Plug>(signify-next-hunk)", {})
vim.api.nvim_set_keymap('n', "[h", "<Plug>(signify-prev-hunk)", {})

-- go to first/last hunks
vim.api.nvim_set_keymap('n', "]H", "9999]h", {})
vim.api.nvim_set_keymap('n', "[H", "9999[h", {})

-- show the current hunk number out of total hunks
vim.cmd[[
autocmd User SignifyHunk call ShowCurrentHunk()

function! ShowCurrentHunk() abort
    let h = sy#util#get_hunk_stats()
    if !empty(h)
        echo printf('[Hunk %d/%d]', h.current_hunk, h.total_hunks)
    endif
endfunction
]]

-- display the added/removed/modified lines in the statusline
-- TODO seems to be bugged, completely overrides the default statusline
-- however, there is no default statusline set (it is empty)
-- so no way to tell what the initial statusline is and add to it
vim.cmd[[
" function! SyStatsWrapper()
"   let [added, modified, removed] = sy#repo#get_stats()
"   let symbols = ['+', '-', '~']
"   let stats = [added, removed, modified]  " reorder
"   let statline = ''

"   for i in range(3)
"     if stats[i] > 0
"       let statline .= printf('%s%s ', symbols[i], stats[i])
"     endif
"   endfor

"   if !empty(statline)
"     let statline = printf('[%s]', statline[:-2])
"   endif

"   return statline
" endfunction

" function! MyStatusline()
"   return ' %f '. SyStatsWrapper()
" endfunction

" set statusline=%!MyStatusline()
]]

-- hunk text objects
vim.api.nvim_set_keymap('o', "ih", "<Plug>(signify-motion-inner-pending)", {})
vim.api.nvim_set_keymap('x', "ih", "<Plug>(signify-motion-inner-visual)", {})
vim.api.nvim_set_keymap('o', "ah", "<Plug>(signify-motion-outer-pending)", {})
vim.api.nvim_set_keymap('x', "ah", "<Plug>(signify-motion-outer-visual)", {})

-- don't link these to the color scheme by default
vim.cmd [[ highlight! SignifySignAdd NONE ]]
vim.cmd [[ highlight! SignifySignChange NONE ]]
vim.cmd [[ highlight! SignifySignDelete NONE ]]
