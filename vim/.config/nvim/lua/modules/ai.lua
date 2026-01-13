return {

    -- LLM code-assistant
    --
    -- also see lua/modules/galaxyline.lua for statusline component
    {
        'olimorris/codecompanion.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-treesitter/nvim-treesitter',
        },
        opts = {
            adapters = {
                acp = {
                    opts = {
                        show_presets = false, -- only show user-defined adapters
                        show_model_choices = true, -- show model choices
                    },
                },
                http = {
                    opts = {
                        show_presets = false, -- only show user-defined adapters
                        show_model_choices = true, -- show model choices
                    },
                    fep = function()
                        return require('codecompanion.adapters').extend('openai_compatible', {
                            name = 'upb.fep',
                            formatted_name = 'UPB fep remote',
                            env = {
                                url = 'http://localhost:34561',
                                chat_url = '/v1/chat/completions',
                                api_key = 'REDACTED',
                            },
                            schema = {
                                model = {
                                    default = 'gpt-oss-120b',
                                },
                            },
                        })
                    end,
                    llama_cpp = function()
                        return require('codecompanion.adapters').extend('openai_compatible', {
                            name = 'llama_cpp',
                            formatted_name = 'llama.cpp local',
                            env = {
                                url = 'http://localhost:11435',
                                chat_url = '/v1/chat/completions',
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
                            schema = {
                                model = {
                                    default = 'gpt-oss-20b',
                                },
                            },
                        })
                    end,
                    riolab_openai = function()
                        return require('codecompanion.adapters').extend('openai', {
                            schema = {
                                model = {
                                    default = 'gpt-5-mini',
                                },
                            },
                            env = {
                                api_key = 'REDACTED',
                            },
                        })
                    end,
                },
            },
            interactions = {
                chat = {
                    adapter = 'fep',
                },
                inline = {
                    adapter = 'fep',
                    keymaps = {
                        accept_change = {
                            modes = { n = '<Leader>gdy' },
                        },
                        reject_change = {
                            modes = { n = '<Leader>gdn' },
                        },
                    },
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
            vim.keymap.set({ 'n', 'v' }, '<Leader>cc', '<Cmd>CodeCompanionChat Toggle<CR>')

            -- add code from current visual selection to chat buffer
            vim.keymap.set('v', 'ga', '<Cmd>CodeCompanionChat Add<CR>')

            -- code actions (Companion Do)
            vim.keymap.set({ 'n', 'v' }, '<Leader>cd', '<Cmd>CodeCompanionActions<CR>')

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
