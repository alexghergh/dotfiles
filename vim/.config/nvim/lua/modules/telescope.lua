return {

    -- smart sorter for files
    {
        'danielfalk/smart-open.nvim',
        branch = '0.2.x',
        dependencies = {
            'kkharji/sqlite.lua',
        },
        config = function()
            -- smart files picker/sorter
            require('telescope').load_extension('smart_open')

            -- note that the plugin (recklessly) overrides <c-w>, so there's some
            -- commmented bits in the plugin code to ignore that binding
            -- see smart-open.nvim/lua/telescope/_extensions/smart_open/picker.lua:~L85
        end,
    },

    -- see :h telescope
    {
        'nvim-telescope/telescope.nvim',
        version = '*',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        opts = {
            defaults = {
                cache_picker = {
                    num_pickers = 100,
                    limit_entries = 1000,
                },
                layout_strategy = 'horizontal',
                layout_config = {
                    horizontal = {
                        prompt_position = 'top',
                        height = 0.5,
                        width = 0.7,
                        preview_width = 0.55,
                    },
                },
            },
        },
        config = function(_, opts)
            local telescope = require('telescope')
            telescope.setup(opts)

            local builtin = require('telescope.builtin')
            -- mnemonics: To Files/Grep/Buffers/Help etc.

            -- file navigation
            vim.keymap.set('n', '<Leader>hh', builtin.find_files, { desc = 'Find files (Telescope)' })
            vim.keymap.set('n', '<Leader>tt', telescope.extensions.smart_open.smart_open, { desc = 'Find files (smart_open)' })
            vim.keymap.set('n', '<Leader>tb', builtin.buffers, { desc = 'Open buffers' })
            vim.keymap.set('n', '<Leader>tgr', builtin.live_grep, { desc = 'Live grep' })

            -- Command/Search History
            vim.keymap.set('n', '<Leader>tch', builtin.command_history, { desc = 'Command line history' })
            vim.keymap.set('n', '<Leader>tsh', builtin.search_history, { desc = 'Search history' })

            -- MArks/Registers
            vim.keymap.set('n', '<Leader>tma', builtin.marks, { desc = 'Marks' })
            vim.keymap.set('n', '<Leader>tr', builtin.registers, { desc = 'Registers' })

            -- Colorschemes
            vim.keymap.set('n', '<Leader>tcs', builtin.colorscheme, { desc = 'Colorschemes' })

            -- Quickfix window
            vim.keymap.set('n', '<Leader>tq', builtin.quickfix, { desc = 'Quickfix list' })

            -- Help Pages/Man Pages (or Harry Potter) (or Get Help)
            vim.keymap.set('n', '<Leader>hp', builtin.help_tags, { desc = 'Help tags' })
            vim.keymap.set('n', '<Leader>thp', builtin.help_tags, { desc = 'Help tags' })
            vim.keymap.set('n', '<Leader>gh', builtin.help_tags, { desc = 'Help tags' })
            vim.keymap.set('n', '<Leader>tmp', builtin.man_pages, { desc = 'Man pages' })

            -- Options/COmmands/AutoCommands/Keymaps
            vim.keymap.set('n', '<Leader>too', builtin.vim_options, { desc = 'Vim options' })
            vim.keymap.set('n', '<Leader>tco', builtin.commands, { desc = 'Commands' })
            vim.keymap.set('n', '<Leader>tac', builtin.autocommands, { desc = 'Autocommands' })
            vim.keymap.set('n', '<Leader>tk', builtin.keymaps, { desc = 'Keymaps' })

            -- HIghlights
            vim.keymap.set('n', '<Leader>thi', builtin.highlights, { desc = 'Color highlights' })

            -- Open Last picker/Open list of All previously opened pickers
            vim.keymap.set('n', '<Leader>tol', builtin.resume, { desc = 'Resume last picker' })
            vim.keymap.set('n', '<Leader>toa', builtin.pickers, { desc = 'Open all previous pickers' })

            -- Git Commits
            vim.keymap.set('n', '<Leader>gg', builtin.git_status, { desc = 'List diffs in current repo' })
            vim.keymap.set('n', '<Leader>gf', builtin.git_files, { desc = 'List all git files under workspace' })
            vim.keymap.set('n', '<Leader>gc', builtin.git_commits, { desc = 'Git commits' })

            -- Lsp (see also lua/modules/lsp.lua)
            vim.keymap.set('n', '<Leader>lgd', builtin.lsp_definitions, { desc = 'LSP definition for symbol under cursor' })
            vim.keymap.set('n', '<Leader>lgi', builtin.lsp_implementations, { desc = 'LSP implementation for symbol under cursor' })
            vim.keymap.set('n', '<Leader>lgr', builtin.lsp_references, { desc = 'LSP references for symbol under cursor' })
            vim.keymap.set('n', '<Leader>li', builtin.lsp_incoming_calls, { desc = 'LSP incoming calls' })
            vim.keymap.set('n', '<Leader>lo', builtin.lsp_outgoing_calls, { desc = 'LSP outgoing calls' })

            -- diagnostics
            vim.keymap.set('n', '<Leader>ld', builtin.diagnostics, { desc = 'Workspace diagnostics' })

            -- treesitter Current Variables
            vim.keymap.set('n', '<Leader>cv', builtin.treesitter, { desc = 'Treesitter symbols (functions, vars etc.)' })
        end,
    },
}
