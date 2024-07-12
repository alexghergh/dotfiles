return {

    -- TODO (comments + more keymaps)
    -- see :h telescope
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        opts = {
            defaults = {
                mappings = {
                    i = {
                        ['<C-h>'] = 'which_key',
                    },
                },
            },
        },
        event = { 'VeryLazy' },
        config = function(_, opts)
            require('telescope').setup(opts)

            local builtin = require('telescope.builtin')
            -- mnemonic To Files/Grep/Buffers/Help etc.

            -- vim stuff
            vim.keymap.set('n', '<Leader>tf', builtin.find_files, {})
            vim.keymap.set('n', '<Leader>tg', builtin.live_grep, {})
            vim.keymap.set('n', '<Leader>tb', builtin.buffers, {})
            vim.keymap.set('n', '<Leader>th', builtin.help_tags, {})

            vim.keymap.set('n', '<Leader>tc', builtin.commands, {})
            vim.keymap.set('n', '<Leader>tch', builtin.command_history, {})
            vim.keymap.set('n', '<Leader>tsh', builtin.search_history, {})
            vim.keymap.set('n', '<Leader>tmp', builtin.man_pages, {}) -- TODO other than man section 1?

            vim.keymap.set('n', '<Leader>tm', builtin.marks, {})

            vim.keymap.set('n', '<Leader>tcs', builtin.colorscheme, {})

            vim.keymap.set('n', '<Leader>tq', builtin.quickfix, {})

            vim.keymap.set('n', '<Leader>to', builtin.vim_options, {})
            vim.keymap.set('n', '<Leader>tr', builtin.registers, {})

            vim.keymap.set('n', '<Leader>ta', builtin.autocommands, {})
            vim.keymap.set('n', '<Leader>tk', builtin.keymaps, {})

            vim.keymap.set('n', '<Leader>thi', builtin.highlights, {})

            vim.keymap.set('n', '<Leader>fr', builtin.resume, {})
            vim.keymap.set('n', '<Leader>fp', builtin.pickers, {})

            -- lsp
            -- TODO definition, references etc. in lsp.lua
            vim.keymap.set('n', '<Leader>lr', builtin.lsp_references, {})
            vim.keymap.set('n', '<Leader>li', builtin.lsp_incoming_calls, {})
            vim.keymap.set('n', '<Leader>lo', builtin.lsp_outgoing_calls, {})

            vim.keymap.set('n', '<Leader>ld', builtin.diagnostics, {})

            -- git stuff
            vim.keymap.set('n', '<Leader>gc', builtin.git_commits, {})

            -- treesitter

            -- lists
        end,
    },
}

-- vim: set tw=0 fo-=r ft=lua
