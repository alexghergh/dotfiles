-- Helper Methods
-- generic helpers for CodeCompanion
-- implement missing ACP functionality, like session load by id, token usage updates etc., and other generic stuff (keymaps etc.)
-- these methods do use internal functionality, so expect breakage on updates

-- determine whether the current chat buffer is "dirty", i.e. has an unsubmitted user text draft
local function chat_has_user_draft(chat)
    if not chat or type(chat.header_line) ~= 'number' or not chat.chat_parser then
        return false
    end

    local ok, drafted = pcall(require('codecompanion.interactions.chat.parser').messages, chat, chat.header_line)
    if not ok or not drafted or type(drafted.content) ~= 'string' then
        return false
    end

    return vim.trim(drafted.content) ~= ''
end

-- on session/list, determine which adapter to use (current chat buffer's adapter if available, or default otherwise)
local function get_preferred_acp_adapter()
    local cc = require('codecompanion')
    local adapters = require('codecompanion.adapters')
    local config = require('codecompanion.config')

    -- obtain the last chat's adapter, if any
    local current_chat = cc.last_chat()
    local current_name = current_chat and current_chat.adapter and current_chat.adapter.type == 'acp' and current_chat.adapter.name
    if type(current_name) == 'string' and current_name ~= '' then
        return current_name
    end

    -- default to the user's default adapter
    local default_adapter = adapters.resolve(config.interactions.chat.adapter)
    local default_name = default_adapter and default_adapter.type == 'acp' and default_adapter.name
    if type(default_name) == 'string' and default_name ~= '' then
        return default_name
    end

    return nil
end

-- determine the chat into which to load an ACP resumed session; if the current chat is "dirty"
-- (has history or an unsent user draft), then load into a new chat buffer, and mark it as such
local function get_target_chat_for_resumed_acp_session()
    local cc = require('codecompanion')

    -- get the last chat and check whether it has history or an unsent user draft message
    local current_chat = cc.last_chat()
    if
        current_chat
        and current_chat.adapter
        and current_chat.adapter.type == 'acp'
        and current_chat.cycle == 1
        and not chat_has_user_draft(current_chat)
    then
        -- if empty chat, then use this chat to resume; didn't create new chat
        return current_chat, false
    end

    -- get the default adapter and create a new chat with it
    local adapter_name = get_preferred_acp_adapter()
    if type(adapter_name) ~= 'string' or adapter_name == '' then
        vim.notify('No ACP adapter available for session resume', vim.log.levels.WARN)
        return nil, false
    end
    local new_chat = cc.chat({
        params = { adapter = adapter_name },
    })
    if not new_chat then
        vim.notify('Failed to create a new CodeCompanion chat with ACP resumed session', vim.log.levels.ERROR)
        return nil, false
    end

    -- created a new chat, use that for ACP session resume
    return new_chat, true
end

-- ensure the chosen chat has an authenticated ACP connection
local function ensure_acp_connection(chat, close_on_failure)
    -- the connection is vim.schedule'd in the setup phase, so we need to vim.wait for it
    local timeout = tonumber(chat and chat.adapter and chat.adapter.defaults and chat.adapter.defaults.timeout) or 20000
    local ok = vim.wait(timeout, function()
        local conn = chat.acp_connection
        return conn and conn:is_ready()
    end)

    -- close new chat if connection failed
    local conn = chat.acp_connection
    if not ok or not conn or not conn:is_ready() then
        if close_on_failure then
            chat:close()
        end
        vim.notify('ACP connection not ready in chat', vim.log.levels.ERROR)
        return false
    end

    return true
end

-- invoke CodeCompanion's built-in /resume workflow; uses a new chat if the current chat is not empty
local function load_acp_session_by_resume()
    local config = require('codecompanion.config')
    local resume = require('codecompanion.interactions.chat.slash_commands.builtin.resume')

    -- obtain the target chat into which to load the session; either this chat or new chat
    local chat, is_new_chat = get_target_chat_for_resumed_acp_session()
    if not chat then
        return false
    end

    if not ensure_acp_connection(chat, is_new_chat) then
        return false
    end

    -- if resume built-in is not enabled, abort
    local enabled, err = resume.enabled(chat)
    if enabled == false then
        if is_new_chat then
            chat:close()
        end
        vim.notify(err, vim.log.levels.WARN)
        return false
    end

    -- execute the built-in resume command
    resume
        ---@diagnostic disable-next-line: missing-fields
        .new({
            Chat = chat,
            config = config.interactions.chat.slash_commands['resume'],
        })
        :execute()

    return true
end

-- load an ACP session by id using CodeCompanion's built-in session/load functionality
local function load_acp_session_by_id(session_id)
    -- obtain the session id; if not passed on the command line, open a vim.ui.input text box
    session_id = type(session_id) == 'string' and vim.trim(session_id) or ''
    if session_id == '' then
        vim.ui.input({ prompt = 'ACP session id to restore: ' }, function(input)
            input = type(input) == 'string' and vim.trim(input) or ''
            if input ~= '' then
                load_acp_session_by_id(input)
            end
        end)
        return
    end

    -- obtain the target chat into which to load the session; either this chat or new chat
    local chat, is_new_chat = get_target_chat_for_resumed_acp_session()
    if not chat or not ensure_acp_connection(chat, is_new_chat) then
        return false
    end

    local conn = chat.acp_connection
    if not conn or not conn:can_load_session() then
        if is_new_chat then
            chat:close()
        end
        vim.notify('Current ACP agent does not support session/load', vim.log.levels.WARN)
        return false
    end

    -- collect the conversation history replay
    local updates = {}
    local ok = conn:load_session(session_id, {
        on_session_update = function(update)
            table.insert(updates, update)
        end,
    })
    if not ok then
        if is_new_chat then
            chat:close()
        end
        vim.notify('session/load failed', vim.log.levels.ERROR)
        return false
    end

    -- setup the chat session and update metadata
    require('codecompanion.interactions.chat.acp.handler').new(chat):ensure_session()
    require('codecompanion.interactions.chat.acp.render').restore_session(chat, updates)
    chat:update_metadata()

    vim.notify('ACP session loaded: ' .. session_id, vim.log.levels.INFO)

    require('codecompanion.utils').fire(
        'ACPChatRestored',
        { bufnr = chat.bufnr, id = chat.id, session_id = conn.session_id, title = chat.title }
    )
    return true
end

-- show the ACP session id for the current chat
local function show_and_yank_chat_session_id()
    -- get the current chat
    local chat = require('codecompanion').last_chat()
    if not chat or not chat.acp_connection then
        return vim.notify('No active ACP CodeCompanion chat', vim.log.levels.WARN)
    end

    local conn = chat.acp_connection
    if not conn or not conn:is_connected() then
        return vim.notify('No ACP session yet connected', vim.log.levels.WARN)
    end

    local session_id = conn.session_id
    vim.notify(string.format('ACP session id: %s (copied to clipboard)', session_id), vim.log.levels.INFO)
    vim.fn.setreg('+', session_id)
end

-- use the system's notify-send to send a toast notification (either on AI message completion, or on tool approval request)
local function toast_notify(title, body)
    -- get the wezterm tab id (unfortunately this is more complicated than a simple translation of pane id -> tab id)
    local pane_num = tonumber(vim.env.WEZTERM_PANE)
    if pane_num then
        local list_result = vim.system({ 'wezterm', 'cli', 'list', '--format', 'json' }, { text = true }):wait()

        -- if wezterm is installed, we have to iterate on the list of results; this is a list of _panes_,
        -- each with a window id, tab id, and pane id; we have to skip other windows, and we have to count
        -- the tab number in the current window
        if list_result.code == 0 then
            local panes = vim.json.decode(list_result.stdout)
            local tab_number = 1
            local last_window_id
            local last_tab_id

            for _, pane in ipairs(panes) do
                if pane.window_id ~= last_window_id then
                    last_window_id = pane.window_id
                    last_tab_id = pane.tab_id
                    tab_number = 1
                elseif pane.tab_id ~= last_tab_id then
                    last_tab_id = pane.tab_id
                    tab_number = tab_number + 1
                end

                if pane.pane_id == pane_num then
                    title = string.format('%s (tab %d)', title, tab_number)
                    break
                end
            end
        end
    end

    local notify_cmd = {
        'notify-send',
        '--app-name',
        title,
        '--expire-time',
        '6000',
        -- always expose a button; we only handle the callback for some configured terminals, see more below
        '--action',
        'open=Go to conversation',
        body,
    }

    -- upon callback, extract whether the button was pressed; if yes, switch
    -- focus back to the conversation when the current terminal supports it
    vim.system(notify_cmd, { text = true }, function(result)
        if result.code ~= 0 or vim.trim(result.stdout or '') ~= 'open' or not pane_num then
            return
        end

        vim.system({ 'wezterm', 'cli', 'activate-pane', '--pane-id', tostring(pane_num) }, { text = true }, function(activate_result)
            if activate_result.code ~= 0 then
                return
            end

            -- only needed on KDE Plasma Wayland as a workaround to focus the Wezterm instance;
            -- X11 / other compositors like sway etc. support this natively
            vim.schedule(function()
                -- the mechanism looks at the wezterm Unix socket, extracts the PID, and
                -- launches kdotool to focus that specific window in the wayland compositor
                local gui_pid = (vim.env.WEZTERM_UNIX_SOCKET or ''):match('gui%-sock%-(%d+)$')
                if
                    not gui_pid
                    or vim.env.XDG_SESSION_TYPE ~= 'wayland'
                    or (vim.env.XDG_CURRENT_DESKTOP or ''):upper():match('KDE') == nil
                    or vim.fn.executable('kdotool') ~= 1
                then
                    return
                end

                vim.system({ 'kdotool', 'search', '--all', '--pid', gui_pid, '.*', 'windowactivate' }, { text = true })
            end)
        end)
    end)
end

-- goto file action using gf in codecompanion chat buffers; this looks at whether there exists a
-- window on the left of the chat, and if yes reuses that, otherwise opens new split on the left
local function goto_file_action(path)
    local current_win = vim.api.nvim_get_current_win()
    vim.cmd.wincmd('h')
    if vim.api.nvim_get_current_win() == current_win then
        vim.cmd('leftabove vertical split')
    end
    vim.cmd.edit(vim.fn.fnameescape(path))
end

-- file path parser for codecompanion chat buffers; prefer markdown links under cursor,
-- but otherwise fall back to regular <cfile> parsing
local function parse_markdown_file_path()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1

    -- match file paths on the line
    for s, target, e in line:gmatch('()%[[^%]]-%]%(([^)]+)%)()') do
        -- check if cursor on the pattern; cursor can also be on the [text] part
        if col >= s and col < e then
            -- parse markdown link targets like path, path#L32, and path#L32-L48
            local parts = vim.fn.matchlist(target, [[^\(.\{-}\)\%(\#L\(\d\+\)\%(-L\d\+\)\?\)\?$]])
            if parts[2] ~= '' then
                -- handle ~ paths
                return vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(parts[2]), ':p')), tonumber(parts[3]) or nil
            end
            return nil
        end
    end

    -- this parses any file under cursor that's not a markdown link
    local cfile = vim.fn.expand('<cfile>')
    if type(cfile) == 'string' and cfile ~= '' then
        return vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(cfile), ':p')), nil
    end
end

return {
    -- LLM code-assistant
    --
    -- also see lua/modules/statusline.lua for statusline component
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
                            formatted_name = '\u{E4C6}  Codex',
                            defaults = {
                                timeout = 20000, -- codecompanion's own timeout is 20 seconds for connection init
                                auth_method = 'chatgpt', -- 'openai-api-key'|'codex-api-key'|'chatgpt'
                            },
                        })
                    end,
                    claude_code = function()
                        return require('codecompanion.adapters').extend('claude_code', {
                            formatted_name = '\u{E4C7}  Claude Code',
                            defaults = {
                                timeout = 20000, -- codecompanion's own timeout is 20 seconds for connection init
                            },
                            env = {
                                -- this requires kwallet on kde
                                CLAUDE_CODE_OAUTH_TOKEN = 'cmd:kwallet-query -r claude_code_oauth -f codecompanion kdewallet',
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
                                -- this requires kwallet on kde
                                api_key = 'cmd:kwallet-query -r riolab_openai_api_key -f codecompanion kdewallet',
                            },
                        })
                    end,
                    riolab_anthropic = function()
                        return require('codecompanion.adapters').extend('anthropic', {
                            env = {
                                -- this requires kwallet on kde
                                api_key = 'cmd:kwallet-query -r riolab_anthropic_api_key -f codecompanion kdewallet',
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
                        -- go to file action (mapped to gf below); this is just the file path opener method
                        goto_file_action = goto_file_action,

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
                        copilot_stats = false, -- interferes with gS jump
                        clear_approvals = false, -- interferes with gt tab movement
                        yolo_mode = false, -- interferes with gt tab movement
                        fold_code = false, -- interferes with gf goto file
                        goto_file_under_cursor = {
                            modes = { n = { 'gf' } }, -- neovim gf, overrides codecompanion's gR
                            description = 'Open file under cursor, with markdown line awareness',
                            -- overwrite gf to accept markdown github-style file + line number paths
                            -- e.g. [file.lua](path/to/file.lua#L32)
                            callback = function()
                                local path, lnum = parse_markdown_file_path()
                                if not path then
                                    return
                                end

                                -- use the above overwritten goto_file_action callback
                                require('codecompanion.config').interactions.chat.opts.goto_file_action(path)

                                -- move to correct line in file, if any
                                vim.api.nvim_win_set_cursor(0, { math.min(lnum or 1, vim.api.nvim_buf_line_count(0)), 0 })
                            end,
                        },
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
            prompt_library = {
                markdown = {
                    dirs = {
                        vim.fs.joinpath(vim.fn.stdpath('config'), 'lua', 'prompts'),
                    },
                },
            },
            rules = {
                opts = {
                    chat = {
                        -- do not autoload stuff like CLAUDE.md or AGENTS.md, since acp agents read
                        -- those by themselves anyway
                        autoload = false,
                    },
                },
            },
            display = {
                action_palette = {
                    provider = 'telescope',
                    opts = {
                        show_preset_prompts = false,
                        show_prompt_library_builtins = false,
                    },
                },
                chat = {
                    auto_scroll = true,
                    fold_context = true,
                    show_header_separator = true,
                    separator = ' ',
                    floating_window = {
                        width = function() -- dynamic detection based on window size
                            return vim.o.columns - 30
                        end,
                        height = function()
                            return vim.o.lines - 12
                        end,
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

            -- show adapter / model / mode info on the currently visible chat header line when:
            --   - chat creation / open / clear / stop reset the visible header line
            --   - submit / done move the visible header line between user and llm headers
            --   - adapter / model / acp mode changes update the metadata shown there
            vim.api.nvim_create_autocmd({ 'User' }, {
                pattern = {
                    'CodeCompanionChatCreated',
                    'CodeCompanionChatOpened',
                    'CodeCompanionChatCleared',
                    'CodeCompanionChatSubmitted',
                    'CodeCompanionChatAdapter',
                    'CodeCompanionChatModel',
                    'CodeCompanionChatDone',
                    'CodeCompanionChatStopped',
                    'CodeCompanionChatACPModeChanged',
                    'CodeCompanionACPChatRestored',
                },
                group = group,
                callback = function(req)
                    local bufnr = (req.data and req.data.bufnr) or req.buf
                    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
                        return
                    end

                    local chat = require('codecompanion').buf_get_chat(bufnr)
                    if not chat or not chat.chat_parser then
                        return
                    end

                    -- if there's an ACP session, we can use model + mode info; otherwise just adapter name
                    local label = chat.adapter and chat.adapter.formatted_name
                    if
                        chat.adapter
                        and chat.adapter.type == 'acp'
                        and chat.acp_connection
                        and type(chat.acp_connection.session_id) == 'string'
                        and chat.acp_connection.session_id ~= ''
                    then
                        local meta = _G.codecompanion_chat_metadata[bufnr] or {}
                        local model = meta.adapter and meta.adapter.model
                        if type(model) == 'function' then
                            model = model()
                        end
                        if type(model) ~= 'string' or model == '' then
                            model = nil
                        end

                        local mode = meta.mode and meta.mode.name
                        if type(mode) ~= 'string' or mode == '' then
                            mode = nil
                        end

                        local suffix
                        if model and mode then
                            suffix = string.format(' |  %s  |  %s  ', model, mode)
                        elseif model or mode then
                            suffix = string.format(' |  %s  ', model or mode)
                        end

                        if suffix then
                            if type(label) == 'string' and label ~= '' then
                                label = label .. suffix
                            else
                                label = suffix
                            end
                        end
                    end

                    local ns_id = vim.api.nvim_create_namespace('CodeCompanionCustomHL')
                    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

                    -- parse the actual visible header line, don't rely on chat.header_line which is unreliable
                    local ok, header_row = pcall(require('codecompanion.interactions.chat.parser').headers, chat)
                    if not ok or type(header_row) ~= 'number' then
                        return
                    end

                    if type(label) ~= 'string' or label == '' then
                        return
                    end

                    pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, header_row, 0, {
                        virt_text = { { label, 'CodeCompanionChatTokens' } },
                        virt_text_pos = 'eol',
                        hl_mode = 'combine',
                    })
                end,
            })

            -- since token session updates are not standardized by ACP, CodeCompanion doesn't
            -- yet implement those; for now, simply parse those manually and update chat tokens;
            -- since the callback handler we hook into is cleared and re-built for every request,
            -- we hook into RequestStarted
            vim.api.nvim_create_autocmd({ 'User' }, {
                pattern = 'CodeCompanionRequestStarted',
                group = group,
                callback = function(req)
                    local bufnr = req.data and req.data.bufnr
                    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
                        return
                    end

                    -- acp connections only
                    local chat = require('codecompanion').buf_get_chat(bufnr)
                    if not chat or not chat.adapter or chat.adapter.type ~= 'acp' or not chat.acp_connection then
                        return
                    end

                    -- get the active callback handler
                    local prompt = chat.acp_connection._active_prompt
                    if not prompt then
                        return
                    end

                    -- wrap the original handle_session_update, if any
                    local original_handle_session_update = prompt.handle_session_update
                    if type(original_handle_session_update) ~= 'function' then
                        return
                    end

                    prompt.handle_session_update = function(prompt_self, update)
                        -- wrapped call
                        original_handle_session_update(prompt_self, update)

                        if type(update) ~= 'table' or update.sessionUpdate ~= 'usage_update' then
                            return
                        end
                        if type(update.used) ~= 'number' then
                            return
                        end

                        chat.ui.tokens = update.used
                        chat:update_metadata()
                    end
                end,
            })

            -- for system toast messages, remember whether the current neovim instance
            -- is focused or not; if it is focused, don't send a toast (used below)
            vim.api.nvim_create_autocmd({ 'FocusGained', 'FocusLost' }, {
                group = group,
                callback = function(ev)
                    -- global per neovim instance / process, across all windows
                    vim.g.wezterm_pane_focused = (ev.event == 'FocusGained')
                end,
            })

            -- show a system toast message:
            -- - when tool use or web access is requested
            -- - upon API response completion
            vim.api.nvim_create_autocmd({ 'User' }, {
                pattern = {
                    'CodeCompanionToolApprovalRequested',
                    'CodeCompanionRequestFinished',
                },
                group = group,
                callback = function(req)
                    local bufnr = (req.data and req.data.bufnr) or req.buf
                    local bufinfo = vim.fn.getbufinfo(bufnr)[1] or {}

                    -- if the current neovim instance is not focused or the chat buffer is
                    -- hidden, send message; otherwise, user sees chat already
                    if vim.g.wezterm_pane_focused ~= nil and vim.g.wezterm_pane_focused == false or bufinfo.hidden == 1 then
                        local chat = require('codecompanion').buf_get_chat(bufnr)
                        if not chat then
                            return
                        end

                        local title, output

                        if req.match == 'CodeCompanionToolApprovalRequested' then
                            title = 'Nvim AI tool approval request'
                            output = string.format(
                                '⚠️ %s requested use for tool: %s\nArgs: %s',
                                chat.adapter.formatted_name,
                                req.data.name,
                                req.data.args
                            )
                        elseif req.match == 'CodeCompanionRequestFinished' then
                            local chat_messages = chat.messages
                            if chat_messages == nil then
                                return
                            end

                            local last_message = chat_messages[#chat_messages].content
                            local body = last_message:sub(1, 100)

                            title = 'Neovim AI response'
                            output = string.format('✅ %s (%s)\n%s', req.data.adapter.formatted_name, req.data.status, body)
                        else
                            return
                        end

                        toast_notify(title, output)
                    end
                end,
            })

            -- user command to load a session
            vim.api.nvim_create_user_command('CodeCompanionSessionLoad', function(session)
                load_acp_session_by_id(session.args)
            end, { nargs = '?' })

            -- user command to show and copy to clipboard a session id for the current chat
            vim.api.nvim_create_user_command('CodeCompanionShowSessionId', function()
                show_and_yank_chat_session_id()
            end, { nargs = 0 })

            -- expand cc to CodeCompanion in the command line
            vim.keymap.set('c', 'cc', "getcmdtype() == ':' ? 'CodeCompanion' : 'cc'", { expr = true })

            -- add code from current visual selection to chat buffer
            vim.keymap.set('v', 'ga', '<Cmd>CodeCompanionChat Add<CR>', { desc = 'Add code from selection to Code companion chat window' })

            -- chat toggle
            vim.keymap.set({ 'n', 'v' }, '<Leader>cc', '<Cmd>CodeCompanionChat Toggle<CR>', { desc = 'Toggle Code companion chat' })

            -- code actions (Companion Do)
            vim.keymap.set({ 'n', 'v' }, '<Leader>cd', '<Cmd>CodeCompanionActions<CR>', { desc = 'Open Code companion actions' })

            -- show the current adapter's model picker
            vim.keymap.set('n', '<leader>cm', function()
                local chat = require('codecompanion').last_chat()
                if not chat then
                    return
                end
                require('codecompanion.interactions.chat.keymaps.change_adapter').select_model(chat)
            end, { desc = 'Open Code companion model picker' })

            -- invoke CodeCompanion's built-in ACP session/list resume picker
            vim.keymap.set(
                'n',
                '<Leader>cl',
                load_acp_session_by_resume,
                { desc = 'List and resume Code companion ACP sessions for current adapter' }
            )

            -- show the current session id, should be easier to resume a future session
            vim.keymap.set(
                'n',
                '<Leader>ci',
                '<Cmd>CodeCompanionShowSessionId<CR>',
                { desc = 'Show current ACP session id for Code companion chat' }
            )

            -- restore ACP session from session id
            vim.keymap.set(
                'n',
                '<Leader>cs',
                '<Cmd>CodeCompanionSessionLoad<CR>',
                { desc = 'Restore Code companion ACP session by session id' }
            )
        end,
    },
}
