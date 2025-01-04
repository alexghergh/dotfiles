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
                        condition = condition.check_git_workspace
                            and condition.hide_in_width,
                        icon = ' +',
                        highlight = 'StatusLineDiffAdd',
                    },
                },
                {
                    DiffRemove = {
                        provider = 'DiffRemove',
                        condition = condition.check_git_workspace
                            and condition.hide_in_width,
                        icon = ' -',
                        highlight = 'StatusLineDiffDelete',
                    },
                },
                {
                    DiffModified = {
                        provider = 'DiffModified',
                        condition = condition.check_git_workspace
                            and condition.hide_in_width,
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
                                return '('
                                    .. vim.fn.argidx() + 1
                                    .. '/'
                                    .. vim.fn.argc()
                                    .. ')'
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
                    FileEncoding = {
                        provider = 'FileEncode',
                        highlight = 'StatusLineColor3',
                        separator = sep(opts.separator_style).R_EMPTY,
                        separator_highlight = 'StatusLineSeparator23',
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
                    FileType = {
                        provider = 'FileTypeName',
                        highlight = 'StatusLineColor3',
                        icon = ' ',
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

-- vim: set tw=0 fo-=r ft=lua
