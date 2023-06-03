-- TODO
-- play with foldcolumn a bit as well, see what happens in files that don't have
-- folds, and see what happens in files that have over 999 lines
-- due to how the column offset is calculated for the hunk preview, a line
-- needed to be commented in the source code so the hunk preview is aligned to
-- the rest of the text
-- file changed: vim-signify/autoload/sy/util.vim - L222

-- see :h signify

-- toggle line highlighting (mnemonic Hunk/Highlight Toggle)
vim.keymap.set('n', '<Leader>ht', '<Cmd>SignifyToggleHighlight<Cr>')

-- open new tab in diff-mode (mnemonic Hunk Open)
vim.keymap.set('n', '<Leader>ho', '<Cmd>SignifyDiff<Cr>')

-- open new tab only with changes unfolded (mnemonic Hunk Fold)
vim.keymap.set('n', '<Leader>hf', '<Cmd>SignifyFold<Cr>')

-- show diff in floating window (mnemonic Hunk Show)
vim.keymap.set('n', '<Leader>hs', '<Cmd>SignifyHunkDiff<Cr>')

-- undo the diff change on the line (mnemonic Hunk Undo)
vim.keymap.set('n', '<Leader>hu', '<Cmd>SignifyHunkUndo<Cr>')

-- go to next/previous Hunks
vim.keymap.set('n', ']h', '<Plug>(signify-next-hunk)')
vim.keymap.set('n', '[h', '<Plug>(signify-prev-hunk)')

-- go to first/last Hunks
vim.keymap.set('n', ']H', '9999]h', { remap = true })
vim.keymap.set('n', '[H', '9999[h', { remap = true })

-- hunk text objects
vim.keymap.set('o', 'ih', '<Plug>(signify-motion-inner-pending)')
vim.keymap.set('x', 'ih', '<Plug>(signify-motion-inner-visual)')
vim.keymap.set('o', 'ah', '<Plug>(signify-motion-outer-pending)')
vim.keymap.set('x', 'ah', '<Plug>(signify-motion-outer-visual)')

-- show the current hunk number out of the total when jumping
vim.api.nvim_create_autocmd('User', {
    pattern = 'SignifyHunk',
    callback = function(event)
        h = vim.fn['sy#util#get_hunk_stats']()
        if h ~= nil then
            print(vim.fn.printf('[Hunk %d/%d]', h.current_hunk, h.total_hunks))
        end
    end,
    group = vim.api.nvim_create_augroup('_user_group', { clear = false })
})

-- TODO add brighter colors, or change the background
-- also, change the Diff highlight groups rather than the signify ones directly
-- don't link these to the color scheme by default
-- vim.cmd [[ highlight! SignifySignAdd NONE ]]
-- vim.cmd [[ highlight! SignifySignChange NONE ]]
-- vim.cmd [[ highlight! SignifySignDelete NONE ]]

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
