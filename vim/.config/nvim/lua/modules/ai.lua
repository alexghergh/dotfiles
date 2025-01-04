return {

    -- AI code-assistant
    {
        'olimorris/codecompanion.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-tresitter/nvim-treesitter',
        },
        opts = {
            adapters = {
                ollama = function()
                    return require('codecompanion.adapters').extend('ollama', {
                        schema = {
                            model = {
                                default = 'codellama:latest',
                            },
                        },
                        num_ctx = {
                            default = 2048,
                        },
                    })
                end,
            },
            display = {
                action_palette = {
                    provider = 'telescope',
                },
            },
            strategies = {
                chat = {
                    adapter = 'ollama',
                },
                inline = {
                    adapter = 'ollama',
                },
            },
        },
        config = function(_, opts)
            require('codecompanion').setup(opts)

            -- chat toggle
            vim.keymap.set(
                { 'n', 'v' },
                '<Leader>cc',
                '<Cmd>CodeCompanionChat Toggle<CR>'
            )

            -- add code from current visual selection to chat buffer
            vim.keymap.set('v', 'ga', '<Cmd>CodeCompanionChat Add<CR>')

            -- code actions (Companion Do)
            vim.keymap.set(
                { 'n', 'v' },
                '<Leader>cd',
                '<Cmd>CodeCompanionActions<CR>'
            )

            -- expand cc to CodeCompanion in the command line
            vim.keymap.set('c', 'cc', 'CodeCompanion')

            -- set this to override _all_ open chat buffers with a specific llm
            -- vim.g.codecompanion_adapter = 'ollama'
        end,
    },
}

-- vim: set tw=0 fo-=r ft=lua
