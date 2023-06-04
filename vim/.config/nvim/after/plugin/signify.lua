-- due to the fact that signify 'hackily' calculates the signcolumn width
-- (because there is no native neovim way to do that), and it happens to be
-- calculated wrongly anyway, a line needs to be commented in the file below
-- file: vim-signify/autoload/sy/util.vim - L222

-- see :h signify

-- toggle line highlighting (mnemonic Hunk/Highlight Toggle)
vim.keymap.set('n', '<Leader>ht', '<Cmd>SignifyToggleHighlight<Cr>')

-- open new tab in diff-mode (mnemonic Hunk Diff)
vim.keymap.set('n', '<Leader>hd', '<Cmd>SignifyDiff<Cr>')

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

-- display added/removed/modified lines in the statusline
-- see after/plugin/statusline.lua
