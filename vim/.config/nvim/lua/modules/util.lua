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
            render = 'wrapped-compact',
            fps = 60,
            top_down = false,
            max_width = vim.o.columns / 2,
        },
        config = function(_, opts)
            require('notify').setup(opts)

            -- open past notifications in telescope
            local telescope = require('telescope')
            telescope.load_extension('notify')
            vim.keymap.set('n', '<Leader>mes', telescope.extensions.notify.notify, { desc = 'Open all vim.notify notifications' })

            -- command line option
            vim.api.nvim_create_user_command('Mes', 'Notifications', {})

            -- replace neovim's built-in notification system
            vim.notify = require('notify')
        end,
    },

    -- remember keymaps
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        opts = {
            preset = 'modern',
            delay = 400,
            win = {
                wo = {
                    winblend = 10,
                },
            },
            replace = {
                desc = {
                    { '<Plug>%((.*)%)', '%1' }, -- fix the default match pattern
                    { '<Plug>(.*)', '%1' }, -- fix the default match pattern
                },
            },
            spec = {
                -- unimpaired keymaps descriptions (these are not directly accessible to which-key
                -- since operator pending mode 'y' takes precedence; the workaround is to simply
                -- start the which-key window with <leader> + <backspace>, then these will appear
                -- normally in 'n' mode)
                { 'yob', desc = 'background color (dark / light)' },
                { 'yoc', desc = 'cursorline' },
                { 'yod', desc = 'diff (actually :diffthis / :diffoff)' },
                { 'yoh', desc = 'hlsearch' },
                { 'yoi', desc = 'ignorecase' },
                { 'yol', desc = 'listchars' },
                { 'yon', desc = 'number line' },
                { 'yor', desc = 'relativenumber' },
                { 'yos', desc = 'spell' },
                { 'yot', desc = 'colorcolumn' },
                { 'you', desc = 'cursorcolumn' },
                { 'yov', desc = 'virtualedit' },
                { 'yow', desc = 'wrap' },
                { 'yox', desc = 'cursorline + cursorcolumn' },
            },
            plugins = {
                spelling = {
                    enabled = false,
                },
            },
        },
        keys = {},
    },
}
