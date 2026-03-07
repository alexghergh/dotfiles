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
            pickers = {
                buffers = {
                    attach_mappings = function(prompt_bufnr, map)
                        local actions = require('telescope.actions')
                        local action_set = require('telescope.actions.set')
                        local action_state = require('telescope.actions.state')

                        -- if no file selected in picker, <CR> with text in the edit line
                        -- will now create a new buffer with that name (as if running :e)
                        actions.select_default:replace(function()
                            local selection = action_state.get_selected_entry()
                            if selection then
                                return action_set.select(prompt_bufnr, 'default')
                            end

                            local name = vim.trim(action_state.get_current_line())
                            if name == '' then
                                return
                            end

                            actions.close(prompt_bufnr)
                            vim.cmd.edit(vim.fn.fnameescape(name))
                        end)

                        map('i', '<A-a>', function(pr_bufnr)
                            -- close buffer picker and open a fresh unnamed buffer (same as :enew)
                            actions.close(pr_bufnr)
                            vim.cmd.enew()
                        end, { desc = 'add_empty_buffer_and_close' })
                        return true
                    end,
                },
            },
            extensions = {
                smart_open = {
                    mappings = {
                        i = {
                            ['<A-u>'] = function(prompt_bufnr)
                                -- move up one directory in smart_open picker
                                local action_state = require('telescope.actions.state')
                                local picker = action_state.get_current_picker(prompt_bufnr)
                                local cwd = tostring(picker.cwd or vim.fn.getcwd())

                                require('telescope.actions').close(prompt_bufnr)
                                require('telescope').extensions.smart_open.smart_open({ cwd = vim.fs.dirname(cwd) })
                            end,
                        },
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
