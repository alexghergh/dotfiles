-- stylua: ignore
local modes_map = {
    n         = 'NORMAL',
    no        = 'O-PENDING',
    nov       = 'O-PENDING',
    noV       = 'O-PENDING',
    ['no\22'] = 'O-PENDING',
    niI       = 'NORMAL',
    niR       = 'NORMAL',
    niV       = 'NORMAL',
    nt        = 'NORMAL',
    ntT       = 'NORMAL',
    v         = 'VISUAL',
    vs        = 'VISUAL',
    V         = 'V-LINE',
    Vs        = 'V-LINE',
    ['\22']   = 'V-BLOCK',
    ['\22s']  = 'V-BLOCK',
    s         = 'SELECT',
    S         = 'S-LINE',
    ['\19']   = 'S-BLOCK',
    i         = 'INSERT',
    ic        = 'INSERT',
    ix        = 'INSERT',
    R         = 'REPLACE',
    Rc        = 'REPLACE',
    Rx        = 'REPLACE',
    Rv        = 'V-REPLACE',
    Rvc       = 'V-REPLACE',
    Rvx       = 'V-REPLACE',
    c         = 'COMMAND',
    cv        = 'EX',
    ce        = 'EX',
    r         = 'REPLACE',
    rm        = 'MORE',
    ['r?']    = 'CONFIRM',
    ['!']     = 'SHELL',
    t         = 'TERMINAL',
}

-- choose statusline separators based on 'style'
local separator_style = 'arrow'

-- statusline element separator style
local function sep(style)
    if style == 'arrow' then
        return { L_FULL = '', L_EMPTY = '', R_FULL = '', R_EMPTY = '' }
    elseif style == 'gaps' then
        return { L_FULL = '', L_EMPTY = '\\', R_FULL = '', R_EMPTY = '/' }
    else
        return { L_FULL = '', L_EMPTY = '|', R_FULL = '', R_EMPTY = '|' }
    end
end

-- inter-element padding
local function padding()
    return ' '
end

local function args_list()
    if vim.fn.argc() > 1 then
        return '(' .. vim.fn.argidx() + 1 .. '/' .. vim.fn.argc() .. ')'
    end
end

-- codecompanion statusline symbols we're using: chat ready, pending tool approval, thinking spinner
-- stylua: ignore
local cc_symbols = {
    chat_ready              = '',
    pending_tool_approval   = '󰀪',
    spinner_list            = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
}

-- the icon glyphs we're using for codecompanion status are drawn at ~1.5 cells, which glitches
-- inside nvim because it assumes width 1; reserve 2 cells for each so the renderer has room and
-- they don't glitch out
-- stylua: ignore
vim.fn.setcellwidths(vim.list_extend(vim.fn.getcellwidths(), {
    { vim.fn.char2nr(cc_symbols.chat_ready),            vim.fn.char2nr(cc_symbols.chat_ready),              2 },
    { vim.fn.char2nr(cc_symbols.pending_tool_approval), vim.fn.char2nr(cc_symbols.pending_tool_approval),   2 },
}))

-- codecompanion statusline provider; shows information on active / running AI chat sessions
-- see also lua/modules/ai.lua
local function codecompanion_status()
    local gl = require('galaxyline')

    -- passed from codecompanion code
    local cc_status = gl.galaxyline_code_companion_buffer_status
    if type(cc_status) ~= 'table' then
        return ' '
    end

    -- this needs to be global to preserve state across function calls
    gl.spinner_idxs = gl.spinner_idxs or {}

    -- keep track of active buffers
    local active_buffers = {}

    -- first, iterate the one off's; these are transient llm calls,
    -- like inline and cmd interactions
    local one_offs_spinners = {}
    for bufnr, val in pairs(cc_status.one_off or {}) do
        if val == 1 then
            local idx = gl.spinner_idxs[bufnr] or 1
            one_offs_spinners[#one_offs_spinners + 1] = cc_symbols.spinner_list[idx]
            active_buffers[bufnr] = true
        end
    end

    -- second, iterate the active open chats (sort by bufnr first, to respect codecompanion cycle
    -- order with `{` and `}`), for which we want to show whether the chat is user-ready, pending
    -- tool approval, or processing; this kind of chat is persistent until it gets closed by the
    -- user; the chat whose buffer is currently focused is rendered with a different highlight so
    -- the active window is unmistakable
    local open_chats_spinners = {}
    local focused_bufnr = vim.api.nvim_get_current_buf()

    -- sort by buf id
    local chat_bufnrs = {}
    for bufnr, _ in pairs(cc_status.chat or {}) do
        chat_bufnrs[#chat_bufnrs + 1] = bufnr
    end
    table.sort(chat_bufnrs)

    -- chat[bufnr] enum shape (set by lua/modules/ai.lua):
    -- 0 = ready, 1 = processing, 2 = pending tool approval
    for ordinal, bufnr in ipairs(chat_bufnrs) do
        local val = cc_status.chat[bufnr]
        local symbol
        if val == 2 then
            symbol = cc_symbols.pending_tool_approval
        elseif val == 1 then
            local idx = gl.spinner_idxs[bufnr] or 1
            symbol = cc_symbols.spinner_list[idx]
            active_buffers[bufnr] = true
        else
            symbol = cc_symbols.chat_ready
        end

        -- pad entries so entry width stays equal and entries don't shift/jiggle; the focused chat
        -- entry is highlighted (see lua/modules/colorschemes.lua)
        symbol = ' ' .. tostring(ordinal) .. ' ' .. symbol .. ' '
        if bufnr == focused_bufnr then
            symbol = '%#CodeCompanionChatFocusedStatusLine#' .. symbol .. '%#StatusLineColor3#'
        end

        open_chats_spinners[#open_chats_spinners + 1] = symbol
    end

    -- delete old inactive spinners; important for transient stuff
    for bufnr, _ in pairs(gl.spinner_idxs) do
        if not active_buffers[bufnr] then
            gl.spinner_idxs[bufnr] = nil
        end
    end

    -- this asynchronously calls itself to update the status line symbols;
    -- if there's no active spinners, or a timer is already running, skip
    if gl.llm_symbol_timer == nil and next(active_buffers) ~= nil then
        gl.llm_symbol_timer = vim.defer_fn(function()
            local any_active = false
            for bufnr, _ in pairs(active_buffers) do
                any_active = true
                local idx = gl.spinner_idxs[bufnr] or 1
                gl.spinner_idxs[bufnr] = (idx % #cc_symbols.spinner_list) + 1
            end
            if any_active then
                gl.load_galaxyline()
            end
            gl.llm_symbol_timer = nil
        end, 120)
    end

    -- finally, return the status line symbols
    local out = ''
    if #one_offs_spinners > 0 then
        out = table.concat(one_offs_spinners, '  ')
    end
    if #open_chats_spinners > 0 then
        if out ~= '' then
            out = out .. ' | '
        end
        out = out .. table.concat(open_chats_spinners)
    end

    return out .. ' '
end

return {
    {
        'nvimdev/galaxyline.nvim',
        config = function(_, opts)
            local gl = require('galaxyline')
            local gls = require('galaxyline').section
            local condition = require('galaxyline.condition')
            local separators = sep(separator_style)

            --
            -- left section
            --
            local left_statusline_section = {
                {
                    EmptySpace1 = {
                        provider = padding,
                        highlight = 'StatusLineColor1',
                    },
                },
                {
                    CurrentMode = {
                        provider = function()
                            return modes_map[vim.fn.mode()] or 'None'
                        end,
                        highlight = 'StatusLineColor1',
                    },
                },
                {
                    EmptySpace2 = {
                        provider = padding,
                        highlight = 'StatusLineColor1',
                        separator = separators.L_FULL,
                        separator_highlight = 'StatusLineSeparator12',
                    },
                },
                {
                    GitBranch = {
                        provider = 'GitBranch',
                        condition = condition.check_git_workspace,
                        icon = '  ',
                        highlight = 'StatusLineColor2',
                    },
                },
                {
                    EmptySpace3 = {
                        provider = padding,
                        highlight = 'StatusLineColor2',
                        separator = separators.L_FULL,
                        separator_highlight = 'StatusLineSeparator23',
                    },
                },
                {
                    DiffAdd = {
                        provider = 'DiffAdd',
                        condition = condition.check_git_workspace,
                        icon = ' +',
                        highlight = 'StatusLineDiffAdd',
                    },
                },
                {
                    DiffRemove = {
                        provider = 'DiffRemove',
                        condition = condition.check_git_workspace,
                        icon = ' -',
                        highlight = 'StatusLineDiffDelete',
                    },
                },
                {
                    DiffModified = {
                        provider = 'DiffModified',
                        condition = condition.check_git_workspace,
                        icon = ' ~',
                        highlight = 'StatusLineDiffChange',
                    },
                },
            }

            --
            -- middle section
            --
            local middle_statusline_section = {
                {
                    FilePath = {
                        provider = 'FilePath',
                        highlight = 'StatusLineColor3',
                    },
                },
                {
                    BufferNumber = {
                        provider = 'BufferNumber',
                        highlight = 'StatusLineColor3',
                    },
                },
                {
                    ArgsList = {
                        provider = args_list,
                        icon = ' ',
                        highlight = 'StatusLineColor3',
                    },
                },
            }

            --
            -- right section
            --
            local right_statusline_section = {
                {
                    CodeCompanion = {
                        provider = codecompanion_status,
                        highlight = 'StatusLineColor3',
                    },
                },
                {
                    EmptySpace4 = {
                        provider = padding,
                        highlight = 'StatusLineColor3',
                    },
                },
                {
                    FileEncoding = {
                        provider = 'FileEncode',
                        highlight = 'StatusLineColor3',
                        separator = separators.R_EMPTY,
                        separator_highlight = 'StatusLineSeparator23',
                    },
                },
                {
                    EmptySpace5 = {
                        provider = padding,
                        highlight = 'StatusLineColor3',
                    },
                },
                {
                    FileType = {
                        provider = 'FileTypeName',
                        highlight = 'StatusLineColor3',
                        icon = ' ',
                        separator = separators.R_EMPTY,
                        separator_highlight = 'StatusLineSeparator23',
                    },
                },
                {
                    EmptySpace6 = {
                        provider = padding,
                        highlight = 'StatusLineColor3',
                    },
                },
                {
                    RowAndColumn = {
                        provider = 'LineColumn',
                        highlight = 'StatusLineColor2',
                        icon = ' ',
                        separator = separators.R_FULL,
                        separator_highlight = 'StatusLineSeparator23',
                    },
                },
                {
                    LinePercent = {
                        provider = 'LinePercent',
                        highlight = 'StatusLineColor2',
                        separator = separators.R_EMPTY,
                        separator_highlight = 'StatusLineColor2',
                    },
                },
            }

            gls.left = left_statusline_section
            gls.mid = middle_statusline_section
            gls.right = right_statusline_section

            -- this is a workaround for galaxyline's highlight rendering in the statusline;
            -- galaxyline wraps every provider's output in `%{luaeval(...)}`, which makes vim escape
            -- `%` items in the result, so an embedded `%#group#` highlight switch would render as
            -- literal text rather than switching highlight groups; nvim _does_ have the `%{%...%}`
            -- form whose result is re-interpreted as statusline format, so we post-process the
            -- generated statusline and rewrite just the CodeCompanion section to use that form
            local cc_needle = [[%{luaeval('require("galaxyline").component_decorator')("CodeCompanion")}]]
            local cc_fixed = [[%{%luaeval('require("galaxyline").component_decorator')("CodeCompanion")%}]]
            local function patch_codecompanion_in_statusline()
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local sl = vim.api.nvim_get_option_value('statusline', { win = win })
                    if sl and sl ~= '' and not sl:find(cc_fixed, 1, true) and sl:find(cc_needle, 1, true) then
                        local new_sl = (
                            sl:gsub(vim.pesc(cc_needle), function()
                                return cc_fixed
                            end)
                        )
                        vim.api.nvim_set_option_value('statusline', new_sl, { win = win })
                    end
                end
            end

            -- galaxyline writes vim.wo.statusline in two paths: the regular redraw path (very badly
            -- named `init_colorscheme()`) and an inactive window cached redraw path; wrap both so
            -- the patch runs correctly on either path
            local orig_init_colorscheme = gl.init_colorscheme
            gl.init_colorscheme = function(...)
                local ret = orig_init_colorscheme(...)
                patch_codecompanion_in_statusline()
                return ret
            end
            local orig_inactive = gl.inactive_galaxyline
            gl.inactive_galaxyline = function(...)
                local ret = orig_inactive(...)
                patch_codecompanion_in_statusline()
                return ret
            end
            patch_codecompanion_in_statusline()
        end,
    },

    -- local per-window statusline
    -- this allows the user to keep a global statusline (i.e. laststatus=3) while still displaying e.g. file paths per window
    {
        'b0o/incline.nvim',
        dependencies = {
            'SmiteshP/nvim-navic',
        },
        event = 'VeryLazy',
        opts = {
            window = {
                padding = 0,
                margin = {
                    horizontal = 3,
                },
            },
            -- this is the main function that renders statusline on each window; display path and breadcrumbs information
            render = function(props)
                local bufnr = props.buf
                local bo = vim.bo[bufnr]
                local path = vim.api.nvim_buf_get_name(bufnr)
                local label = '[No Name]' -- empty buffers

                local focused = props.focused -- neovim window focus
                local on_first_line = vim.api.nvim_win_get_cursor(props.win)[1] == 1

                local separator = sep(separator_style).R_FULL
                local hl_suffix = focused and '' or 'NC' -- current or non-current window hl
                local sep_suffix = hl_suffix .. (on_first_line and 'CL' or '') -- swap separator bg on the incline line

                -- incline highlight groups
                local status1_group = 'InclineStatus1' .. hl_suffix
                local status2_group = 'InclineStatus2' .. hl_suffix
                local separator01_group = 'InclineSeparator01' .. sep_suffix
                local separator10_group = 'InclineSeparator10' .. sep_suffix
                local separator02_group = 'InclineSeparator02' .. sep_suffix
                local separator20_group = 'InclineSeparator20' .. sep_suffix

                -- path is trimmed; compact version on active window; relative path on inactive windows
                if path ~= '' then
                    label = vim.fn.fnamemodify(path, focused and ':t' or ':.')
                    local max_chars = 70
                    local label_len = vim.fn.strchars(label)
                    if label_len > max_chars then
                        label = '..' .. vim.fn.strcharpart(label, label_len - (max_chars - 1), max_chars - 1)
                    end
                end

                -- add buffer state
                if bo.modified then
                    label = label .. ' [+]'
                end
                if bo.readonly or not bo.modifiable then
                    label = label .. ' [ro]'
                end

                -- reserve breadcrumbs for the active window and cap width by trimming older context
                if focused then
                    local navic = require('nvim-navic')
                    if navic.is_available(bufnr) then
                        local location = navic.get_location({
                            depth_limit = 4,
                            depth_limit_indicator = '..',
                        }, bufnr)

                        -- build location hl
                        if location ~= '' then
                            return {
                                { separator, group = separator01_group },
                                { ' ' .. location .. ' ', group = status1_group },
                                { separator, group = separator10_group },
                                { separator, group = separator02_group },
                                { ' ' .. label .. ' ', group = status2_group },
                                { separator, group = separator20_group },
                            }
                        end
                    end
                end

                -- regular no-breadcrumbs exit
                return {
                    { separator, group = separator02_group },
                    { ' ' .. label .. ' ', group = status2_group },
                    { separator, group = separator20_group },
                }
            end,
        },
        config = function(_, opts)
            require('incline').setup(opts)
        end,
    },
}
