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

-- codecompanion statusline provider; shows information on active / running AI chat sessions
-- see also lua/modules/ai.lua
local function codecompanion_status()
    local gl = require('galaxyline')

    -- passed from codecompanion code
    local cc_status = gl.galaxyline_code_companion_buffer_status
    if type(cc_status) ~= 'table' then
        return ' '
    end

    -- stylua: ignore
    local spinner_list = {
        "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"
    }

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
            one_offs_spinners[#one_offs_spinners + 1] = spinner_list[idx]
            active_buffers[bufnr] = true
        end
    end

    -- second, iterate the active open chats, for which we want
    -- to show whether the chat is user-ready or processing; this kind
    -- of chat is persistent until it gets closed by the user
    local open_chats_spinners = {}
    for bufnr, val in pairs(cc_status.chat or {}) do
        if val == 1 then
            local idx = gl.spinner_idxs[bufnr] or 1
            open_chats_spinners[#open_chats_spinners + 1] = spinner_list[idx]
            active_buffers[bufnr] = true
        else
            open_chats_spinners[#open_chats_spinners + 1] = ''
        end
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
                gl.spinner_idxs[bufnr] = (idx % #spinner_list) + 1
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
        out = out .. table.concat(open_chats_spinners, '  ')
    end

    return out
end

return {
    {
        'nvimdev/galaxyline.nvim',
        config = function(_, opts)
            local condition = require('galaxyline.condition')
            local gls = require('galaxyline').section
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

                local separator = sep(separator_style).R_FULL
                local hl_suffix = focused and '' or 'NC' -- current or non-current window hl

                -- incline highlight groups
                local status1_group = 'InclineStatus1' .. hl_suffix
                local status2_group = 'InclineStatus2' .. hl_suffix
                local separator01_group = 'InclineSeparator01' .. hl_suffix
                local separator10_group = 'InclineSeparator10' .. hl_suffix
                local separator02_group = 'InclineSeparator02' .. hl_suffix
                local separator20_group = 'InclineSeparator20' .. hl_suffix

                -- path is trimmed; compact version on active window; full path on inactive windows
                if path ~= '' then
                    label = vim.fn.fnamemodify(path, focused and ':t' or ':~')
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
