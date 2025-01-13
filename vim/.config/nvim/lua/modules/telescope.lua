return {

    -- TODO (comments + more keymaps)
    -- see :h telescope
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        event = { 'VeryLazy' },
        config = function(_, opts)
            require('telescope').setup(opts)

            local builtin = require('telescope.builtin')
            -- mnemonics: To Files/Grep/Buffers/Help etc.

            -- file navigation
            vim.keymap.set('n', '<Leader>hh', builtin.find_files, {})
            vim.keymap.set('n', '<Leader>tt', builtin.find_files, {})
            vim.keymap.set('n', '<Leader>tb', builtin.buffers, {})
            vim.keymap.set('n', '<Leader>tg', builtin.live_grep, {})

            -- Command/Search History
            vim.keymap.set('n', '<Leader>tch', builtin.command_history, {})
            vim.keymap.set('n', '<Leader>tsh', builtin.search_history, {})

            -- MArks/Registers
            vim.keymap.set('n', '<Leader>tma', builtin.marks, {})
            vim.keymap.set('n', '<Leader>tr', builtin.registers, {})

            -- Colorschemes
            vim.keymap.set('n', '<Leader>tcs', builtin.colorscheme, {})

            -- Quickfix window
            vim.keymap.set('n', '<Leader>tq', builtin.quickfix, {})

            -- Help Pages/Man Pages
            vim.keymap.set('n', '<Leader>thp', builtin.help_tags, {})
            vim.keymap.set('n', '<Leader>tmp', builtin.man_pages, {})

            -- Options/COmmands/AutoCommands/Keymaps
            vim.keymap.set('n', '<Leader>to', builtin.vim_options, {})
            vim.keymap.set('n', '<Leader>tco', builtin.commands, {})
            vim.keymap.set('n', '<Leader>tac', builtin.autocommands, {})
            vim.keymap.set('n', '<Leader>tk', builtin.keymaps, {})

            -- HIghlights
            vim.keymap.set('n', '<Leader>thi', builtin.highlights, {})

            -- Resume (open last picker)/Open all pickers
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
