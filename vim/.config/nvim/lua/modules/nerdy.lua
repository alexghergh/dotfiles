return {

    -- better UI
    {
        'stevearc/dressing.nvim',
        opts = {},
        event = { 'VeryLazy' },
    },

    -- glyphs, symbols
    {
        '2kabhishek/nerdy.nvim',
        dependencies = {
            'stevearc/dressing.nvim',
            'nvim-telescope/telescope.nvim',
        },
        config = function()
            local telescope = require('telescope')

            telescope.load_extension('nerdy')

            -- GLyphs
            vim.keymap.set(
                'n',
                '<Leader>gl',
                telescope.extensions.nerdy.nerdy,
                {}
            )
        end,
    },
}

-- vim: set tw=0 fo-=r ft=lua
