return {

    -- LLM code-assistant
    --
    -- also see lua/modules/galaxyline.lua for statusline component
    {
        'olimorris/codecompanion.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-tresitter/nvim-treesitter',
        },
        opts = {
            adapters = {
                llama_cpp = function()
                    return require('codecompanion.adapters').extend('openai_compatible', {
                        name = 'llama_cpp',
                        env = {
                            url = "http://localhost:11435",
                            chat_url = "/v1/chat/completions",
                        },
                        num_ctx = {
                            default = 4096,
                        },
                        handlers = {
                            chat_output = function(self, data)
                                -- there's an issue with llama.cpp not adding
                                -- 'role' to its outputs, so we add it manually
                                local openai = require('codecompanion.adapters.openai')
                                local output = openai.handlers.chat_output(self, data)
                                if output ~= nil then
                                    output.output.role = 'assistant'
                                end
                                return output
                            end,
                        },
                    })
                end,
            },
            strategies = {
                chat = {
                    adapter = 'llama_cpp',
                },
                inline = {
                    adapter = 'llama_cpp',
                },
            },
            display = {
                action_palette = {
                    provider = 'telescope',
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
            vim.keymap.set(
                'c',
                'cc',
                "getcmdtype() == ':' ? 'CodeCompanion' : 'cc'",
                { expr = true }
            )

            -- set this to override _all_ open chat buffers with a specific llm
            -- vim.g.codecompanion_adapter = 'ollama'

            -- visual statusline indication when the LLM is processing input
            local status, galaxyline = pcall(require, 'galaxyline')
            if status ~= false then
                local group = vim.api.nvim_create_augroup('CodeCompanion', {})

                vim.api.nvim_create_autocmd({ 'User' }, {
                    pattern = 'CodeCompanionRequest*',
                    group = group,
                    callback = function(req)
                        if req.match == 'CodeCompanionRequestStarted' then
                            galaxyline.llm_processing = true
                        elseif req.match == 'CodeCompanionRequestFinished' then
                            galaxyline.llm_processing = false
                        end
                        galaxyline.load_galaxyline()
                    end,
                })
            end
        end,
    },
}

-- vim: set tw=0 fo-=r ft=lua
