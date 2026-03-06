-- Helper Methods
-- generic helpers for CodeCompanion sessions
-- implement missing ACP functionality, like session load and session list
-- these methods do use some internal functionality, so expect breakage in the future

-- translate received information (Json-RPC data) into human-readable text messages
local function acp_replay_render_content(content)
    if type(content) == 'string' then
        return content
    end
    if type(content) == 'table' then
        if content.type then
            if content.type == 'text' and type(content.text) == 'string' then
                return content.text
            end
            if content.type == 'resource_link' and type(content.uri) == 'string' then
                return ('[resource: %s]'):format(content.uri)
            end
            if content.type == 'resource' and content.resource then
                if type(content.resource.text) == 'string' then
                    return content.resource.text
                end
                if type(content.resource.uri) == 'string' then
                    return ('[resource: %s]'):format(content.resource.uri)
                end
            end
            if content.type == 'image' then
                return '[image]'
            end
            if content.type == 'audio' then
                return '[audio]'
            end
            return nil
        end
        local parts = {}
        for _, item in ipairs(content) do
            local text = acp_replay_render_content(item)
            if text and text ~= '' then
                table.insert(parts, text)
            end
        end
        return table.concat(parts, '')
    end
    return nil
end

-- handle an ACP session/load replay from the server; receive Json-RPC messages and append
-- to CodeCompnanion chat buffer
local function handle_replay(chat, config, update, replay_state)
    if type(update) ~= 'table' then
        return
    end
    local text = acp_replay_render_content(update.content)
    if not text or text == '' then
        return
    end
    -- stylua: ignore start
    if update.sessionUpdate == 'user_message_chunk' then
        chat:add_buf_message(
            { role = config.constants.USER_ROLE, content = text },
            { type = chat.MESSAGE_TYPES.USER_MESSAGE }
        )
        chat:add_message(
            { role = config.constants.USER_ROLE, content = text },
            { _meta = { sent = true, replay = true } }
        )
    elseif update.sessionUpdate == 'agent_message_chunk' then
        chat:add_buf_message(
            { role = config.constants.LLM_ROLE, content = text },
            { type = chat.MESSAGE_TYPES.LLM_MESSAGE }
        )
        local reasoning = nil
        if replay_state.reasoning ~= '' then
            reasoning = replay_state.reasoning
            replay_state.reasoning = ''
        end
        chat:add_message(
            { role = config.constants.LLM_ROLE, content = text, reasoning = reasoning },
            { _meta = { replay = true } }
        )
    elseif update.sessionUpdate == 'agent_thought_chunk' then
        chat:add_buf_message(
            { role = config.constants.LLM_ROLE, content = text },
            { type = chat.MESSAGE_TYPES.REASONING_MESSAGE }
        )
        replay_state.reasoning = replay_state.reasoning .. text
    end
    -- stylua: ignore end
end

-- load an ACP session (creates a new buffer, so it doesn't share history with the current conversation)
-- it uses ACP's session/load method, which currently is exposed by CodeCompanion but unused /
-- unimplemented
-- upon calling session/load, a full replay of the conversation by the server is sent through
-- session/prompt messages
-- this method restores the conversation context (not tool calls etc, just user messages + agent
-- messages / reasoning traces)
-- the conversation context is restored both visually (in the chat window) and as a
-- message context buffer for CodeCompanion internals
-- if session/load fails, we just close the new buffer and keep the current chat as-is
-- if session/load succeeds, we close the old chat and open the new one
local function load_acp_session_buffer(session_id)
    local cc = require('codecompanion')
    local config = require('codecompanion.config')
    local METHODS = require('codecompanion.acp.methods')

    -- get the current chat window context
    local old_chat = cc.last_chat()
    if not old_chat or not old_chat.acp_connection then
        vim.notify('No active ACP CodeCompanion chat', vim.log.levels.WARN)
        return false
    end

    -- obtain the active connection
    local old_conn = old_chat.acp_connection
    if not old_conn or not old_conn:is_connected() then
        vim.notify('ACP connection not ready', vim.log.levels.WARN)
        return false
    end

    if old_conn._active_prompt then
        vim.notify('ACP prompt already running; try again after it finishes', vim.log.levels.WARN)
        return false
    end

    if type(session_id) ~= 'string' or session_id == '' then
        vim.notify('Invalid session id', vim.log.levels.ERROR)
        return false
    end

    local old_adapter_name = old_chat.adapter and old_chat.adapter.name
    if type(old_adapter_name) ~= 'string' or old_adapter_name == '' then
        vim.notify('Unable to determine ACP adapter for current chat', vim.log.levels.ERROR)
        return false
    end

    -- create a new hidden chat first, so if session/load fails we can keep old chat
    -- this chat inherits the old chat's adapter
    local new_chat = cc.chat({
        hidden = true,
        params = { adapter = old_adapter_name },
    })
    if not new_chat then
        vim.notify('Failed to create a new CodeCompanion chat', vim.log.levels.ERROR)
        return false
    end

    if not new_chat.acp_connection then
        require('codecompanion.interactions.chat.helpers').create_acp_connection(new_chat)
    end

    local new_conn = new_chat.acp_connection
    if not new_conn or not new_conn:is_connected() then
        new_chat:close()
        vim.notify('ACP connection not ready in new chat', vim.log.levels.ERROR)
        return false
    end

    -- prepare the session/prompt handler to handle replayed messages during session/load request
    local prev_prompt = new_conn._active_prompt
    ---@diagnostic disable-next-line: missing-fields
    new_conn._active_prompt = {
        handle_session_update = function(_, update)
            -- reasoning goes under LLM role, but has a separate "section" into the chat buffer
            local replay_state = { reasoning = '' }
            handle_replay(new_chat, config, update, replay_state)
        end,
        -- ignore other stuff during replay, just record user / agent messages
    }

    -- try to switch session id using ACP session/load
    new_conn.session_id = session_id
    local ok = new_conn:send_rpc_request(METHODS.SESSION_LOAD, {
        sessionId = session_id,
        cwd = vim.fn.getcwd(),
        mcpServers = (new_chat.adapter.defaults and new_chat.adapter.defaults.mcpServers) or {},
    })
    new_conn._active_prompt = prev_prompt

    if not ok then
        new_chat:close()
        vim.notify('session/load failed', vim.log.levels.ERROR)
        return false
    end

    -- link buffer to the new session id for ACP commands / completions
    -- not sure whether this is actually needed
    require('codecompanion.interactions.chat.acp.commands').link_buffer_to_session(new_chat.bufnr, session_id)
    new_chat:update_metadata()

    -- ensure a fresh user prompt header is available
    -- adapted from interactions/chat/init.lua:ready_chat_buffer()
    if new_chat._last_role ~= config.constants.USER_ROLE then
        new_chat.cycle = new_chat.cycle + 1
        new_chat:add_buf_message({ role = config.constants.USER_ROLE, content = '' })
        new_chat.header_line = vim.api.nvim_buf_line_count(new_chat.bufnr) - 2
        new_chat.ui:display_tokens(new_chat.chat_parser, new_chat.header_line)
        new_chat.context:render()
        new_chat:dispatch('on_ready')
    end
    new_chat:reset()

    vim.notify('ACP session loaded: ' .. session_id, vim.log.levels.INFO)

    -- on success close old chat and open new one
    old_chat:close()
    new_chat.ui:open()
    return true
end

-- show the ACP session id for the current chat
local function show_chat_session_id()
    -- get the current chat
    local chat = require('codecompanion').last_chat()
    if not chat or not chat.acp_connection then
        return vim.notify('No active ACP CodeCompanion chat', vim.log.levels.WARN)
    end

    -- obtain the active connection
    local conn = chat.acp_connection
    if not conn or not conn:is_connected() then
        return vim.notify('ACP connection not ready', vim.log.levels.WARN)
    end

    local session_id = conn.session_id
    if type(session_id) ~= 'string' or session_id == '' then
        return vim.notify('No ACP session id available', vim.log.levels.WARN)
    end

    vim.notify(string.format('ACP session id: %s (copied to clipboard)', session_id), vim.log.levels.INFO)
    vim.fn.setreg('+', session_id)
end

-- list ACP sessions using session/list, which is not exposed / implemented by
-- CodeCompanion (the method itself is still in RFC)
local function list_acp_sessions()
    -- get the current chat
    local chat = require('codecompanion').last_chat()
    if not chat or not chat.acp_connection then
        return vim.notify('No active ACP CodeCompanion chat', vim.log.levels.WARN)
    end

    -- obtain the active connection
    local conn = chat.acp_connection
    if not conn or not conn:is_connected() then
        return vim.notify('ACP connection not ready', vim.log.levels.WARN)
    end

    -- check if the ACP client actually supports session list
    local supports_list = conn._agent_info
        and conn._agent_info.agentCapabilities
        and conn._agent_info.agentCapabilities.sessionCapabilities
        and conn._agent_info.agentCapabilities.sessionCapabilities.list ~= nil
    if not supports_list then
        return vim.notify('Current ACP agent does not support session/list', vim.log.levels.WARN)
    end

    local sessions = {}
    local cursor = nil

    -- session/list may be paginated; fetch all results repeatedly
    for _ = 1, 1000 do
        local params = { cwd = vim.fn.getcwd() }
        if type(cursor) == 'string' and cursor ~= '' then
            params.cursor = cursor
        end

        local result = conn:send_rpc_request('session/list', params)
        if not result or type(result.sessions) ~= 'table' then
            return vim.notify('session/list failed', vim.log.levels.ERROR)
        end

        vim.list_extend(sessions, result.sessions)

        local next_cursor = result.nextCursor
        if type(next_cursor) ~= 'string' or next_cursor == '' or next_cursor == cursor then
            break
        end
        cursor = next_cursor
    end

    if #sessions == 0 then
        return vim.notify('No ACP sessions found for this cwd', vim.log.levels.INFO)
    end

    -- newest first
    table.sort(sessions, function(a, b)
        local a_updated_at = type(a.updatedAt) == 'string' and a.updatedAt or ''
        local b_updated_at = type(b.updatedAt) == 'string' and b.updatedAt or ''
        return a_updated_at > b_updated_at
    end)

    -- use telescope for session picking
    local has_telescope = pcall(require, 'telescope')
    if not has_telescope then
        return vim.notify('Telescope is required for session picker', vim.log.levels.ERROR)
    end

    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    local session_display = function(session)
        local updated_at = type(session.updatedAt) == 'string' and session.updatedAt or '[unknown time]'
        local title = type(session.title) == 'string' and session.title ~= '' and session.title
            or type(session.sessionId) == 'string' and session.sessionId ~= '' and session.sessionId
            or '[untitled]'
        local cwd = type(session.cwd) == 'string' and session.cwd ~= '' and session.cwd or '[no cwd]'
        return string.format('%s  %s  (%s)', updated_at, title, cwd)
    end

    pickers
        .new({}, {
            prompt_title = string.format('ACP Sessions for %s adapter', conn.adapter.formatted_name),
            finder = finders.new_table({
                results = sessions,
                entry_maker = function(session)
                    local display = session_display(session)
                    return {
                        value = session,
                        display = display,
                        ordinal = table.concat({
                            session.sessionId or '',
                            session.title or '',
                            session.cwd or '',
                            session.updatedAt or '',
                        }, ' '),
                    }
                end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)

                    local session = selection and selection.value or nil
                    local session_id = session and session.sessionId or nil
                    if type(session_id) ~= 'string' or session_id == '' then
                        return vim.notify('Invalid session selection', vim.log.levels.ERROR)
                    end

                    vim.cmd('CodeCompanionSessionLoad ' .. vim.fn.fnameescape(session_id))
                end)
                return true
            end,
        })
        :find()
end

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
                    claude_code = function()
                        return require('codecompanion.adapters').extend('claude_code', {
                            env = {
                                CLAUDE_CODE_OAUTH_TOKEN = 'REDACTED',
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
                                        if string.match(model, '5%.') then -- codex / chatgpt 5.x models
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
                        -- remove default system prompt for acp agents (these usually come with their
                        -- own, and modifying e.g. AGENTS.md is usually better than system prompt)
                        system_prompt = function(ctx)
                            if ctx.adapter and ctx.adapter.type == 'acp' then
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
                    keymaps = {
                        copilot_stats = false, -- unbind copilot_stats keymap (default gS, interferes with jump)
                    },
                },
                inline = {
                    adapter = 'llama_cpp',
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
                    adapter = 'llama_cpp',
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
                    floating_window = {
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
                    window = {
                        buflisted = true,
                    },
                },
            },
            extensions = {
                history = {
                    opts = {
                        -- don't auto-save chats; this is turned off since ACP connections have
                        -- their own history, and saving them using history wouldn't work either;
                        -- technically, this plugin only works for HTTP LLM connections
                        auto_save = false,
                        save_chat_keymap = '<Leader>sc',

                        auto_generate_title = false,
                        continue_last_chat = false,
                    },
                },
            },
        },
        config = function(_, opts)
            require('codecompanion').setup(opts)

            -- set this to override _all_ open chat buffers with a specific llm
            -- vim.g.codecompanion_adapter = 'ollama'

            local group = vim.api.nvim_create_augroup('CodeCompanion', {})

            -- visual statusline indication when an LLM is processing input
            -- we're actually sending a list of currently open chat buffers; this way
            -- we can have a status indicator per LLM session; inline and cmd interactions
            -- also get an indicator, but they're not directly associated with chat buffers,
            -- they are instead bound to the current (non-CodeCompanion) open buffer
            local status, gl = pcall(require, 'galaxyline')
            if status ~= false then
                local function get_galaxyline_status_table()
                    if gl.galaxyline_code_companion_buffer_status == nil then
                        gl.galaxyline_code_companion_buffer_status = {
                            chat = {},
                            one_off = {},
                        }
                    end

                    local status_table = gl.galaxyline_code_companion_buffer_status
                    status_table.chat = status_table.chat or {}
                    status_table.one_off = status_table.one_off or {}
                    return status_table
                end

                -- on request started / finished, update the status
                vim.api.nvim_create_autocmd({ 'User' }, {
                    pattern = 'CodeCompanionRequest*',
                    group = group,
                    callback = function(req)
                        local bufnr = req.data.bufnr
                        local interaction = req.data.interaction
                        local status_table = get_galaxyline_status_table()

                        if req.match == 'CodeCompanionRequestStarted' then
                            if interaction == 'chat' then
                                status_table.chat[bufnr] = 1
                            else
                                status_table.one_off[bufnr] = 1
                            end
                        elseif req.match == 'CodeCompanionRequestFinished' then
                            if interaction == 'chat' then
                                status_table.chat[bufnr] = 0
                            else
                                status_table.one_off[bufnr] = nil
                            end
                        end

                        gl.load_galaxyline()
                    end,
                })

                -- on chat created, append a new buffer to status
                vim.api.nvim_create_autocmd({ 'User' }, {
                    pattern = 'CodeCompanionChatCreated',
                    group = group,
                    callback = function(req)
                        local bufnr = req.data and req.data.bufnr
                        if bufnr then
                            get_galaxyline_status_table().chat[bufnr] = 0
                        end
                        gl.load_galaxyline()
                    end,
                })

                -- on chat closed, delete the buffer from the status
                vim.api.nvim_create_autocmd({ 'User' }, {
                    pattern = 'CodeCompanionChatClosed',
                    group = group,
                    callback = function(req)
                        local bufnr = req.data and req.data.bufnr
                        if bufnr then
                            get_galaxyline_status_table().chat[bufnr] = nil
                        end
                        gl.load_galaxyline()
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

            -- show a system toast message when tool use or web access is requested
            vim.api.nvim_create_autocmd({ 'User' }, {
                pattern = 'CodeCompanionToolApprovalRequested',
                group = group,
                callback = function(req)
                    -- if the current neovim instance is not focused or the chat buffer is
                    -- hidden, send message; otherwise, user sees chat already
                    if
                        vim.g.wezterm_pane_focused ~= nil and vim.g.wezterm_pane_focused == false
                        or vim.fn.getbufinfo(req.data.bufnr)[1].hidden == 1
                    then
                        local output = string.format('⚠️ %s requested use for tool: %s', req.data.adapter.formatted_name, req.data.name)

                        -- use the system's notify-send to send a toast notification
                        vim.system(
                            { 'notify-send', '--app-name', 'Nvim AI tool approval request', '--expire-time', '6000', output },
                            { text = true }
                        )
                    end
                end,
            })

            -- show a system toast message upon API response completion
            vim.api.nvim_create_autocmd({ 'User' }, {
                pattern = 'CodeCompanionRequestFinished',
                group = group,
                callback = function(req)
                    -- if the current neovim instance is not focused or the chat buffer is
                    -- hidden, send message; otherwise, user sees chat already
                    if
                        vim.g.wezterm_pane_focused ~= nil and vim.g.wezterm_pane_focused == false
                        or vim.fn.getbufinfo(req.data.bufnr)[1].hidden == 1
                    then
                        local chat_messages = require('codecompanion').buf_get_chat(req.data.bufnr).messages

                        if chat_messages ~= nil then
                            local last_message = chat_messages[#chat_messages].content
                            local body = last_message:sub(1, 100)

                            local output = string.format('✅ %s (%s)\n%s', req.data.adapter.formatted_name, req.data.status, body)

                            -- use the system's notify-send to send a toast notification
                            vim.system(
                                { 'notify-send', '--app-name', 'Neovim AI response', '--expire-time', '6000', output },
                                { text = true }
                            )
                        end
                    end
                end,
            })

            -- show tokens / model / mode in header line
            vim.api.nvim_create_autocmd({ 'User' }, {
                pattern = 'CodeCompanionRequestFinished',
                group = group,
                callback = function(req)
                    local bufnr = req.data.bufnr
                    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
                        return
                    end

                    local chat = require('codecompanion').buf_get_chat(bufnr)
                    if not chat or not chat.acp_connection then -- doesn't make sense on non-ACP connections
                        return
                    end

                    -- approximate token usage, as CodeCompanion doesn't yet update it,
                    -- due to not being standardized by ACP; draft RFC open
                    local token_utils = require('codecompanion.utils.tokens')
                    local approx = 0
                    for _, msg in ipairs(chat.messages or {}) do
                        if msg.content and msg.content ~= '' then
                            approx = approx + token_utils.calculate(msg.content)
                        end
                        local reasoning = msg.reasoning
                        if reasoning and reasoning ~= '' then
                            if type(reasoning) == 'string' then
                                approx = approx + token_utils.calculate(reasoning)
                            elseif type(reasoning) == 'table' and reasoning.content then
                                approx = approx + token_utils.calculate(reasoning.content)
                            end
                        end
                    end

                    -- update token count in the UI
                    if approx > 0 then
                        chat.ui.tokens = approx
                        chat:update_metadata()
                        chat.ui:display_tokens(chat.chat_parser, chat.header_line)
                    end

                    -- add model and mode information in the UI
                    local meta = _G.codecompanion_chat_metadata[bufnr] or {}
                    local model = meta.adapter and (meta.adapter.model or meta.adapter.name) or nil
                    local mode_name = meta and meta.mode and meta.mode.name

                    local label = string.format(' |  %s  |  %s  ', model, mode_name)

                    local ns_id = vim.api.nvim_create_namespace('CodeCompanionCustomHL')
                    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
                    local ok, err = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, chat.header_line - 1, 0, {
                        virt_text = { { label, 'CodeCompanionChatTokens' } },
                        virt_text_pos = 'eol',
                        hl_mode = 'combine',
                    })
                    if not ok then
                        vim.notify(
                            string.format('CodeCompanion extmark error: %s, with header line: %d', tostring(err), chat.header_line),
                            vim.log.levels.ERROR
                        )
                    end
                end,
            })

            -- show the adapter used in the header line on chat creation
            -- if the adapter changes, but the buffer is still empty (no LLM messages),
            -- we need to show it as well (i.e. we need to update the shown model)
            vim.api.nvim_create_autocmd({ 'User' }, {
                pattern = { 'CodeCompanionChatCreated', 'CodeCompanionChatAdapter' },
                group = group,
                callback = function(req)
                    local bufnr = req.data.bufnr
                    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
                        return
                    end

                    local chat = require('codecompanion').buf_get_chat(bufnr)
                    if not chat then
                        return
                    end

                    local ns_id = vim.api.nvim_create_namespace('CodeCompanionCustomHL')
                    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

                    local ok, err = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, chat.header_line - 1, 0, {
                        virt_text = { { chat.adapter.formatted_name, 'CodeCompanionChatTokens' } },
                        virt_text_pos = 'eol',
                        hl_mode = 'combine',
                    })
                    if not ok then
                        vim.notify(
                            string.format('CodeCompanion extmark error: %s, with header line: %d', tostring(err), chat.header_line),
                            vim.log.levels.ERROR
                        )
                    end
                end,
            })

            -- user command to load a session with a specified id
            vim.api.nvim_create_user_command('CodeCompanionSessionLoad', function(session)
                load_acp_session_buffer(session.args)
            end, { nargs = 1 })

            -- user command to list sessions for the current ACP agent/session cwd
            vim.api.nvim_create_user_command('CodeCompanionSessionList', function()
                list_acp_sessions()
            end, { nargs = 0 })

            -- user command to show a session id for the current chat
            vim.api.nvim_create_user_command('CodeCompanionShowSessionId', function()
                show_chat_session_id()
            end, { nargs = 0 })

            -- chat toggle
            vim.keymap.set({ 'n', 'v' }, '<Leader>cc', '<Cmd>CodeCompanionChat Toggle<CR>', { desc = 'Toggle Code companion chat' })

            -- add code from current visual selection to chat buffer
            vim.keymap.set('v', 'ga', '<Cmd>CodeCompanionChat Add<CR>', { desc = 'Add code from selection to Code companion chat window' })

            -- code actions (Companion Do)
            vim.keymap.set({ 'n', 'v' }, '<Leader>cd', '<Cmd>CodeCompanionActions<CR>', { desc = 'Open Code companion actions' })

            -- expand cc to CodeCompanion in the command line
            vim.keymap.set('c', 'cc', "getcmdtype() == ':' ? 'CodeCompanion' : 'cc'", { expr = true })

            -- list CodeCompanion sessions (works on ACP sessions only through session/list capability)
            vim.keymap.set(
                'n',
                '<Leader>cs',
                '<Cmd>CodeCompanionSessionList<CR>',
                { desc = 'List Code companion ACP sessions for current adapter and cwd' }
            )

            -- show the current session id, should be easier to resume a future session
            vim.keymap.set(
                'n',
                '<Leader>ci',
                '<Cmd>CodeCompanionShowSessionId<CR>',
                { desc = 'Show current ACP session id for Code companion chat' }
            )
        end,
    },
}
