return {

    -- nvim-wezterm integration
    -- see :h smart-splits.txt
    {
        'mrjones2014/smart-splits.nvim',
        opts = {
            at_edge = 'stop',
            cursor_follows_swapped_bufs = true,
            float_win_behaviour = 'mux',
        },
        config = function(_, opts)
            require('smart-splits').setup(opts)
            local splits = require('smart-splits')

            -- move cursor
            vim.keymap.set('n', '<A-h>', splits.move_cursor_left, { desc = 'Move to left window' })
            vim.keymap.set('n', '<A-l>', splits.move_cursor_right, { desc = 'Move to right window' })
            vim.keymap.set('n', '<A-j>', splits.move_cursor_down, { desc = 'Move to below window' })
            vim.keymap.set('n', '<A-k>', splits.move_cursor_up, { desc = 'Move to above window' })

            -- resize split (these intentionally override the keymaps set in
            -- lua/core/keymaps.lua, so we have a uniform keybind set even if this plugin is
            -- not available)
            vim.keymap.set('n', '<Leader>wh', splits.resize_left, { desc = 'Resize window left' })
            vim.keymap.set('n', '<Leader>wl', splits.resize_right, { desc = 'Resize window right' })
            vim.keymap.set('n', '<Leader>wj', splits.resize_down, { desc = 'Resize window down' })
            vim.keymap.set('n', '<Leader>wk', splits.resize_up, { desc = 'Resize window up' })

            -- swap neovim splits
            vim.keymap.set('n', '<Leader><Leader>h', splits.swap_buf_left, { desc = 'Swap window left' })
            vim.keymap.set('n', '<Leader><Leader>l', splits.swap_buf_right, { desc = 'Swap window right' })
            vim.keymap.set('n', '<Leader><Leader>j', splits.swap_buf_down, { desc = 'Swap window down' })
            vim.keymap.set('n', '<Leader><Leader>k', splits.swap_buf_up, { desc = 'Swap window up' })
        end,
    },
}
