-- due to the fact that signify 'hackily' calculates the signcolumn width
-- (because there is no native neovim way to do that), and it happens to be
-- calculated wrongly anyway, a line needs to be commented in the file below
-- ~ vim-signify/autoload/sy/util.vim - L222
--
-- see :h signify
--

if vim.g.loaded_signify == nil then
    return
end

-- toggle line highlighting (mnemonic Hunk/Highlight Toggle)
vim.keymap.set('n', '<Leader>ht', '<Cmd>SignifyToggleHighlight<CR>')

-- open new tab in diff-mode (mnemonic Hunk Diff)
vim.keymap.set('n', '<Leader>hd', '<Cmd>SignifyDiff<CR>')

-- open new tab only with changes unfolded (mnemonic Hunk Fold)
vim.keymap.set('n', '<Leader>hf', '<Cmd>SignifyFold<CR>')

-- show diff in floating window (mnemonic Hunk Show)
vim.keymap.set('n', '<Leader>hs', '<Cmd>SignifyHunkDiff<CR>')

-- undo the diff change on the line (mnemonic Hunk Undo)
vim.keymap.set('n', '<Leader>hu', '<Cmd>SignifyHunkUndo<CR>')

-- go to next/previous Hunks (mapped by default)
-- vim.keymap.set('n', ']c', '<Plug>(signify-next-hunk)')
-- vim.keymap.set('n', '[c', '<Plug>(signify-prev-hunk)')

-- go to first/last Hunks (mapped by default)
-- vim.keymap.set('n', ']C', '9999]c', { remap = true })
-- vim.keymap.set('n', '[C', '9999[c', { remap = true })

-- hunk text objects
vim.keymap.set('o', 'ic', '<Plug>(signify-motion-inner-pending)')
vim.keymap.set('x', 'ic', '<Plug>(signify-motion-inner-visual)')
vim.keymap.set('o', 'ac', '<Plug>(signify-motion-outer-pending)')
vim.keymap.set('x', 'ac', '<Plug>(signify-motion-outer-visual)')

-- show the current hunk number out of the total when jumping
vim.api.nvim_create_autocmd('User', {
    pattern = 'SignifyHunk',
    callback = function(_)
        local h = vim.fn['sy#util#get_hunk_stats']()
        if h ~= nil then
            print(vim.fn.printf('[Hunk %d/%d]', h.current_hunk, h.total_hunks))
        end
    end,
    group = vim.api.nvim_create_augroup('_user_group', { clear = false }),
})

-- display added/removed/modified lines in the statusline
-- see API in lua/statusline.lua
function DiffStats()
    -- table as [added, modified, removed]
    return vim.fn['sy#repo#get_stats']()
end
