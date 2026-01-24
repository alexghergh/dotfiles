return {

    -- goodies and other utilities for rainy days
    {
        'nvim-lua/plenary.nvim',
        lazy = true,
    },

    {
        'folke/snacks.nvim',
        opts = {
            input = { -- better vim.ui.input
            },
            styles = {
                input = {
                    row = -20,
                },
            },
        }
    },
}
