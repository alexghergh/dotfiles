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
            splits = require('smart-splits')

            -- move cursor
            vim.keymap.set('n', '<A-h>', splits.move_cursor_left)
            vim.keymap.set('n', '<A-l>', splits.move_cursor_right)
            vim.keymap.set('n', '<A-j>', splits.move_cursor_down)
            vim.keymap.set('n', '<A-k>', splits.move_cursor_up)

            -- resize split (these intentionally override the keymaps set in
            -- lua/core/keymaps.lua, so we have a uniform keybind set even if this plugin is
            -- not available)
            vim.keymap.set('n', '<Leader>wh', splits.resize_left)
            vim.keymap.set('n', '<Leader>wl', splits.resize_right)
            vim.keymap.set('n', '<Leader>wj', splits.resize_down)
            vim.keymap.set('n', '<Leader>wk', splits.resize_up)

            -- swap neovim splits
            vim.keymap.set('n', '<Leader><Leader>h', splits.swap_buf_left)
            vim.keymap.set('n', '<Leader><Leader>j', splits.swap_buf_down)
            vim.keymap.set('n', '<Leader><Leader>k', splits.swap_buf_up)
            vim.keymap.set('n', '<Leader><Leader>l', splits.swap_buf_right)
        end,
    },
}
