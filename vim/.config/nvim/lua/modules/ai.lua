return {

    -- LLM session history (see settings in 'extensions' config below)
    {
        'ravitemer/codecompanion-history.nvim',
    },

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
                    codex = function()
                        return require('codecompanion.adapters').extend('codex', {
                            defaults = {
                                auth_method = 'chatgpt', -- 'openai-api-key'|'codex-api-key'|'chatgpt'
                            },
                        })
                    end,
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
                            },
                            handlers = {
                                -- correctly format reasoning content if there's any
                                parse_message_meta = function(_, data)
                                    local extra = data.extra

                                    -- sglang
                                    if extra.reasoning_content then
                                        -- codecompanion expects the reasoning tokens in this format
                                        data.output.reasoning = { content = extra.reasoning_content }
                                        if data.output.content == '' then
                                            data.output.content = nil
                                        end
                                    end

                                    -- vllm
                                    if extra.reasoning then
                                        data.output.reasoning = { content = extra.reasoning }
                                    end
                                    return data
                                end,
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
                                -- correctly format reasoning content if there's any
                                parse_message_meta = function(_, data)
                                    local extra = data.extra
                                    if extra.reasoning_content then
                                        -- codecompanion expect the reasoning tokens in this format
                                        data.output.reasoning = { content = extra.reasoning_content }
                                        if data.output.content == '' then
                                            data.output.content = nil
                                        end
                                    end
                                    return data
                                end,
                            },
                        })
                    end,
                    riolab_openai = function()
                        return require('codecompanion.adapters').extend('openai_responses', {
                            env = {
                                api_key = 'REDACTED',
                            },
                            schema = {
                                model = {
                                    default = 'gpt-5.2-codex',
                                    -- see https://platform.openai.com/docs/pricing
                                    choices = {
                                        ['gpt-5.2'] = {
                                            formatted_name = 'GPT‑5.2 ($14 output)',
                                            opts = {
                                                has_function_calling = true,
                                                has_vision = true,
                                                can_reason = true,
                                            },
                                        },
                                        ['gpt-5.1'] = {
                                            formatted_name = 'GPT‑5.1 ($10 output)',
                                            opts = {
                                                has_function_calling = true,
                                                has_vision = true,
                                                can_reason = true,
                                            },
                                        },
                                        ['gpt-5'] = {
                                            formatted_name = 'GPT‑5 ($10 output)',
                                            opts = {
                                                has_function_calling = true,
                                                has_vision = true,
                                                can_reason = true,
                                            },
                                        },
                                        ['gpt-5-mini'] = {
                                            formatted_name = 'GPT‑5 Mini ($2 output)',
                                            opts = {
                                                has_function_calling = true,
                                                has_vision = true,
                                                can_reason = true,
                                            },
                                        },
                                        ['gpt-5-nano'] = {
                                            formatted_name = 'GPT‑5 Nano ($0.40 output)',
                                            opts = {
                                                has_function_calling = true,
                                                has_vision = true,
                                                can_reason = true,
                                            },
                                        },
                                        ['gpt-5.2-chat-latest'] = {
                                            formatted_name = 'GPT‑5.2 Chat (Latest) ($14 output)',
                                            opts = {
                                                has_function_calling = true,
                                                has_vision = true,
                                                can_reason = true,
                                            },
                                        },
                                        ['gpt-5.1-chat-latest'] = {
                                            formatted_name = 'GPT‑5.1 Chat (Latest) ($10 output)',
                                            opts = {
                                                has_function_calling = true,
                                                has_vision = true,
                                            },
                                        },
                                        ['gpt-5-chat-latest'] = {
                                            formatted_name = 'GPT‑5 Chat (Latest) ($10 output)',
                                            opts = {
                                                has_function_calling = true,
                                                has_vision = true,
                                            },
                                        },
                                        ['gpt-5.2-codex'] = {
                                            formatted_name = 'GPT‑5.2 Codex ($14 output)',
                                            opts = {
                                                has_function_calling = true,
                                                has_vision = true,
                                                can_reason = true,
                                            },
                                        },
                                        ['gpt-5.1-codex'] = {
                                            formatted_name = 'GPT‑5.1 Codex ($10 output)',
                                            opts = {
                                                has_function_calling = true,
                                                has_vision = true,
                                                can_reason = true,
                                            },
                                        },
                                        ['gpt-5.1-codex-max'] = {
                                            formatted_name = 'GPT‑5.1 Codex Max ($10 output)',
                                            opts = {
                                                has_function_calling = true,
                                                has_vision = true,
                                                can_reason = true,
                                            },
                                        },
                                        ['gpt-5-codex'] = {
                                            formatted_name = 'GPT‑5 Codex ($10 output)',
                                            opts = {
                                                has_function_calling = true,
                                                has_vision = true,
                                                can_reason = true,
                                            },
                                        },
                                        ['gpt-5.2-pro'] = {
                                            formatted_name = 'GPT‑5.2 Pro ($168 output)',
                                            opts = {
                                                has_function_calling = true,
                                                has_vision = true,
                                                can_reason = true,
                                                stream = false,
                                            },
                                        },
                                        ['gpt-5-pro'] = {
                                            formatted_name = 'GPT‑5 Pro ($120 output)',
                                            opts = {
                                                has_function_calling = true,
                                                has_vision = true,
                                                can_reason = true,
                                                stream = false,
                                            },
                                        },
                                    },
                                },
                                ['reasoning.effort'] = {
                                    default = 'high', -- high, medium, low, minimal
                                    enabled = function(self)
                                        local model = self.schema.model.default
                                        if type(model) == 'function' then
                                            model = model()
                                        end
                                        if string.match(model, '5.') then -- codex / chatgpt 5.x models
                                            return false
                                        end
                                        return true
                                    end,
                                },
                                top_p = {
                                    default = 1,
                                    enabled = function(self)
                                        local model = self.schema.model.default
                                        if type(model) == 'function' then
                                            model = model()
                                        end
                                        if string.match(model, 'codex') or string.match(model, '5.') then -- codex / chatgpt 5.x models
                                            return false
                                        end
                                        return true
                                    end,
                                },
                            },
                        })
                    end,
                    riolab_anthropic = function()
                        return require('codecompanion.adapters').extend('anthropic', {
                            env = {
                                api_key = 'REDACTED',
                            },
                        })
                    end,
                },
            },
            interactions = {
                chat = {
                    adapter = 'codex',
                    variables = {
                        ['buffer'] = {
                            opts = {
                                default_params = 'diff',
                            },
                        },
                    },
                    opts = {
                        -- remove default system prompt for codex
                        system_prompt = function(ctx)
                            if ctx.adapter and ctx.adapter.name == 'codex' then
                                return ''
                            end
                            return ctx.default_system_prompt
                        end,
                    },
                    tools = {
                        opts = {
                            -- remove default tools system prompt
                            system_prompt = {
                                enabled = false,
                            },
                        },
                    },
                },
                inline = {
                    adapter = 'codex',
                    keymaps = {
                        accept_change = {
                            -- diff yes
                            modes = { n = '<Leader>gdy' },
                        },
                        reject_change = {
                            -- diff no
                            modes = { n = '<Leader>gdn' },
                        },
                    },
                },
                cmd = {
                    adapter = 'codex',
                },
            },
            display = {
                action_palette = {
                    provider = 'telescope',
                },
                chat = {
                    auto_scroll = true,
                    icons = {
                        chat_context = '📎️',
                    },
                    fold_context = true,
                    show_header_separator = true,
                    separator = ' ',
                    debug_window = {
                        width = vim.o.columns - 30,
                        height = vim.o.lines - 12,
                        relative = 'editor',
                        opts = {
                            wrap = false,
                            number = false,
                            relativenumber = false,
                            signcolumn = 'no',
                        },
                    },
                },
            },
            extensions = {
                history = {
                    opts = {
                        auto_generate_title = false,
                        continue_last_chat = false,
                    },
                },
            },
        },
        config = function(_, opts)
            require('codecompanion').setup(opts)

            -- chat toggle
            vim.keymap.set({ 'n', 'v' }, '<Leader>cc', '<Cmd>CodeCompanionChat Toggle<CR>', { desc = 'Toggle Code companion chat' })

            -- add code from current visual selection to chat buffer
            vim.keymap.set('v', 'ga', '<Cmd>CodeCompanionChat Add<CR>', { desc = 'Add code from selection to Code companion chat window' })

            -- code actions (Companion Do)
            vim.keymap.set({ 'n', 'v' }, '<Leader>cd', '<Cmd>CodeCompanionActions<CR>', { desc = 'Open Code companion actions' })

            -- expand cc to CodeCompanion in the command line
            vim.keymap.set('c', 'cc', "getcmdtype() == ':' ? 'CodeCompanion' : 'cc'", { expr = true })

            -- set this to override _all_ open chat buffers with a specific llm
            -- vim.g.codecompanion_adapter = 'ollama'

            local group = vim.api.nvim_create_augroup('CodeCompanion', {})

            -- visual statusline indication when the LLM is processing input
            local status, galaxyline = pcall(require, 'galaxyline')
            if status ~= false then
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

            -- for system toast messages, remember whether the current neovim instance
            -- is focused or not; if it is focused, don't send a toast (used below)
            vim.api.nvim_create_autocmd({ 'FocusGained', 'FocusLost' }, {
                group = group,
                callback = function(ev)
                    -- global per neovim instance / process, across all windows
                    vim.g.wezterm_pane_focused = (ev.event == 'FocusGained')
                end,
            })

            -- show a system toast message upon API response completion
            vim.api.nvim_create_autocmd({ 'User' }, {
                pattern = 'CodeCompanionRequestFinished',
                group = group,
                callback = function(req)
                    -- if we're focused, don't send message, user sees chat already
                    if vim.g.wezterm_pane_focused ~= nil and not vim.g.wezterm_pane_focused then
                        -- technically undocumented internal function
                        local chat_messages = require('codecompanion').buf_get_chat(req.buf)['messages']

                        if chat_messages ~= nil then
                            local last_message = chat_messages[#chat_messages]['content']
                            local body = last_message:sub(1, 100)

                            -- use the system's notify-send to send a toast notification
                            vim.system({ 'notify-send', '--app-name', 'Nvim AI response', '--expire-time', '2000', body }, { text = true })
                        end
                    end
                end,
            })

            -- show a system toast message when tool use or web access is requested
            vim.api.nvim_create_autocmd({ 'User' }, {
                pattern = 'CodeCompanionToolApprovalRequested',
                group = group,
                callback = function(req)
                    -- if we're focused, don't send message, user sees chat already
                    if vim.g.wezterm_pane_focused ~= nil and not vim.g.wezterm_pane_focused then
                        local body = string.format('Requested use for tool: %s', req.data.name)

                        -- use the system's notify-send to send a toast notification
                        vim.system(
                            { 'notify-send', '--app-name', 'Nvim AI tool approval request', '--expire-time', '2000', body },
                            { text = true }
                        )
                    end
                end,
            })
        end,
    },
}
