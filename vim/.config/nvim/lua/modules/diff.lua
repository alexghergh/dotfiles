return {

    -- code diffs
    -- see :h signify
    {
        'mhinz/vim-signify',
        config = function()
            -- toggle line highlighting (mnemonic Hunk/Highlight Toggle)
            vim.keymap.set('n', '<Leader>ht', '<Cmd>SignifyToggleHighlight<CR>', { desc = 'Toggle diff highlight' })

            -- open new tab in diff-mode (mnemonic Hunk Diff)
            vim.keymap.set('n', '<Leader>hd', '<Cmd>SignifyDiff<CR>', { desc = 'Open new tab in diff mode' })

            -- open new tab only with changes unfolded (mnemonic Hunk Fold)
            vim.keymap.set('n', '<Leader>hf', '<Cmd>SignifyFold<CR>', { desc = 'Open new tab in diff mode (non-diffs folded)' })

            -- show diff in floating window (mnemonic Hunk Show)
            vim.keymap.set('n', '<Leader>hs', '<Cmd>SignifyHunkDiff<CR>', { desc = 'Show diff under cursor' })

            -- undo the diff change on the line (mnemonic Hunk Undo)
            vim.keymap.set('n', '<Leader>hu', '<Cmd>SignifyHunkUndo<CR>', { desc = 'Undo diff under cursor' })

            -- hunk text objects
            vim.keymap.set('o', 'ih', '<Plug>(signify-motion-inner-pending)', { desc = 'Diff inner' })
            vim.keymap.set('x', 'ih', '<Plug>(signify-motion-inner-visual)', { desc = 'Diff inner' })
            vim.keymap.set('o', 'ah', '<Plug>(signify-motion-outer-pending)', { desc = 'Diff outer' })
            vim.keymap.set('x', 'ah', '<Plug>(signify-motion-outer-visual)', { desc = 'Diff outer' })

            -- hunk navigation
            vim.keymap.set('n', ']h', '<Plug>(signify-next-hunk)', { desc = 'Move to next diff' })
            vim.keymap.set('n', '[h', '<Plug>(signify-prev-hunk)', { desc = 'Move to previous diff' })
            vim.keymap.set('n', ']H', '9999]h', { remap = true, desc = 'Move to last diff' })
            vim.keymap.set('n', '[H', '9999[h', { remap = true, desc = 'Move to first diff' })

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
        end,
    },
}
