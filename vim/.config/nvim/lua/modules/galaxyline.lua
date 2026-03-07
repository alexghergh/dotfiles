--
-- choose statusline separators based on 'style'
local function sep(style)
    if style == 'arrow' then
        -- stylua: ignore
        return { L_FULL = '', L_EMPTY = '', R_FULL = '', R_EMPTY = '' }
    elseif style == 'gaps' then
        return { L_FULL = '', L_EMPTY = '\\', R_FULL = '', R_EMPTY = '/' }
    else
        return { L_FULL = '', L_EMPTY = '|', R_FULL = '', R_EMPTY = '|' }
    end
end

return {
    {
        'nvimdev/galaxyline.nvim',
        opts = {
            separator_style = 'arrow',
        },
        config = function(_, opts)
            local gl = require('galaxyline')
            local condition = require('galaxyline.condition')
            local gls = require('galaxyline').section

            --
            -- left section
            --
            local left_statusline_section = {
                {
                    EmptySpace1 = {
                        -- stylua: ignore
                        provider = function() return ' ' end,
                        highlight = 'StatusLineColor1',
                    },
                },
                {
                    CurrentMode = {
                        provider = function()
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
                            return modes_map[vim.fn.mode()] or 'None'
                        end,
                        highlight = 'StatusLineColor1',
                    },
                },
                {
                    EmptySpace2 = {
                        -- stylua: ignore
                        provider = function() return ' ' end,
                        highlight = 'StatusLineColor1',
                        separator = sep(opts.separator_style).L_FULL,
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
                        -- stylua: ignore
                        provider = function() return ' ' end,
                        highlight = 'StatusLineColor2',
                        separator = sep(opts.separator_style).L_FULL,
                        separator_highlight = 'StatusLineSeparator23',
                    },
                },
                {
                    DiffAdd = {
                        provider = 'DiffAdd',
                        condition = condition.check_git_workspace and condition.hide_in_width,
                        icon = ' +',
                        highlight = 'StatusLineDiffAdd',
                    },
                },
                {
                    DiffRemove = {
                        provider = 'DiffRemove',
                        condition = condition.check_git_workspace and condition.hide_in_width,
                        icon = ' -',
                        highlight = 'StatusLineDiffDelete',
                    },
                },
                {
                    DiffModified = {
                        provider = 'DiffModified',
                        condition = condition.check_git_workspace and condition.hide_in_width,
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
                        provider = function()
                            if vim.fn.argc() > 1 then
                                return '(' .. vim.fn.argidx() + 1 .. '/' .. vim.fn.argc() .. ')'
                            end
                        end,
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
                        provider = function()
                            -- see also lua/modules/ai.lua
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
                        end,
                        highlight = 'StatusLineColor3',
                    },
                },
                {
                    EmptySpace4 = {
                        -- stylua: ignore
                        provider = function() return ' ' end,
                        highlight = 'StatusLineColor3',
                    },
                },
                {
                    FileEncoding = {
                        provider = 'FileEncode',
                        highlight = 'StatusLineColor3',
                        separator = sep(opts.separator_style).R_EMPTY,
                        separator_highlight = 'StatusLineSeparator23',
                    },
                },
                {
                    EmptySpace5 = {
                        -- stylua: ignore
                        provider = function() return ' ' end,
                        highlight = 'StatusLineColor3',
                    },
                },
                {
                    FileType = {
                        provider = 'FileTypeName',
                        highlight = 'StatusLineColor3',
                        icon = ' ',
                        separator = sep(opts.separator_style).R_EMPTY,
                        separator_highlight = 'StatusLineSeparator23',
                    },
                },
                {
                    EmptySpace6 = {
                        -- stylua: ignore
                        provider = function() return ' ' end,
                        highlight = 'StatusLineColor3',
                    },
                },
                {
                    RowAndColumn = {
                        provider = 'LineColumn',
                        highlight = 'StatusLineColor2',
                        icon = ' ',
                        separator = sep(opts.separator_style).R_FULL,
                        separator_highlight = 'StatusLineSeparator23',
                    },
                },
                {
                    LinePercent = {
                        provider = 'LinePercent',
                        highlight = 'StatusLineColor2',
                        separator = sep(opts.separator_style).R_EMPTY,
                        separator_highlight = 'StatusLineColor2',
                    },
                },
            }

            for _, item in ipairs(left_statusline_section) do
                table.insert(gls.left, item)
            end

            for _, item in ipairs(middle_statusline_section) do
                table.insert(gls.mid, item)
            end

            for _, item in ipairs(right_statusline_section) do
                table.insert(gls.right, item)
            end
        end,
    },
}
