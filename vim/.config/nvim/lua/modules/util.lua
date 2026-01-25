return {

    -- goodies and other utilities for rainy days
    {
        'nvim-lua/plenary.nvim',
        lazy = true,
    },

    -- custom vim.ui.select implementation
    {
        'nvim-telescope/telescope-ui-select.nvim',
        config = function()
            require('telescope').load_extension('ui-select')
        end,
    },

    -- custom vim.ui.input implementation
    {
        'folke/snacks.nvim',
        opts = {
            input = {},
            styles = {
                input = {
                    row = -20,
                },
            },
        },
    },

    -- custom vim.notify implementation
    {
        'rcarriga/nvim-notify',
        opts = {
            render = 'compact',
            fps = 60,
            timeout = 2,
            top_down = false,
        },
        config = function(_, opts)
            require('notify').setup(opts)

            -- open past notifications in telescope
            local telescope = require('telescope')
            telescope.load_extension('notify')
            vim.keymap.set('n', '<Leader>mes', telescope.extensions.notify.notify, {})

            -- command line option
            vim.api.nvim_create_user_command('Mes', 'Notifications', {})

            -- replace neovim's built-in notification system
            vim.notify = require('notify')
        end,
    },
}
