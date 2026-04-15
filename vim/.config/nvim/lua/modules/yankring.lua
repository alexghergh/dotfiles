return {
    -- nvim yank ring
    {
        'gbprod/yanky.nvim',
        dependencies = {
            'nvim-telescope/telescope.nvim',
        },
        opts = {
            system_clipboard = {
                sync_with_ring = false,
            },
        },
        config = function(_, opts)
            require('yanky').setup(opts)

            -- put
            vim.keymap.set({ 'n', 'x' }, 'p', '<Plug>(YankyPutAfter)')
            vim.keymap.set({ 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)')
            vim.keymap.set({ 'n', 'x' }, 'gp', '<Plug>(YankyGPutAfter)') -- leave cursor just after the text
            vim.keymap.set({ 'n', 'x' }, 'gP', '<Plug>(YankyGPutBefore)')

            -- unimpaired-style put mappings
            vim.keymap.set('n', '=p', '<Plug>(YankyPutAfterFilter)')
            vim.keymap.set('n', '=P', '<Plug>(YankyPutBeforeFilter)')

            -- indent after put
            vim.keymap.set('n', ']p', '<Plug>(YankyPutIndentAfterLinewise)')
            vim.keymap.set('n', '[p', '<Plug>(YankyPutIndentBeforeLinewise)')
            vim.keymap.set('n', ']P', '<Plug>(YankyPutIndentAfterLinewise)')
            vim.keymap.set('n', '[P', '<Plug>(YankyPutIndentBeforeLinewise)')

            -- put with indent / dedent
            vim.keymap.set('n', '>p', '<Plug>(YankyPutIndentAfterShiftRight)')
            vim.keymap.set('n', '<p', '<Plug>(YankyPutIndentAfterShiftLeft)')
            vim.keymap.set('n', '>P', '<Plug>(YankyPutIndentBeforeShiftRight)')
            vim.keymap.set('n', '<P', '<Plug>(YankyPutIndentBeforeShiftLeft)')

            -- cycle yank ring put
            vim.keymap.set('n', '<C-p>', '<Plug>(YankyPreviousEntry)')
            vim.keymap.set('n', '<C-n>', '<Plug>(YankyNextEntry)')

            -- yank (this doesn't move the cursor to beginning of region on yank)
            vim.keymap.set({ 'n', 'x' }, 'y', '<Plug>(YankyYank)')

            -- yank ring telescope picker
            local telescope = require('telescope')
            telescope.load_extension('yank_history')
            vim.keymap.set('n', '<Leader>ty', telescope.extensions.yank_history.yank_history, { desc = 'Open yank ring history' })

            -- clear yank ring
            vim.keymap.set('n', '<Leader>yc', '<Cmd>YankyClearHistory<CR>', { desc = 'Clear yank ring history' })
        end,
    },
}
