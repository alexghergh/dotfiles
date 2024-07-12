--
-- choose statusline separators based on 'style'
local function sep(style)
    if style == 'arrow' then
        -- stylua: ignore
        return {
            LSIDE_FULL  = '',
            LSIDE_EMPTY = '',
            RSIDE_FULL  = '',
            RSIDE_EMPTY = '',
        }
    elseif style == 'gaps' then
        -- stylua: ignore
        return {
            LSIDE_FULL  = '', -- this might not render properly in certain fonts
            LSIDE_EMPTY = '\\',
            RSIDE_FULL  = '', -- this might not render properly in certain fonts
            RSIDE_EMPTY = '/',
        }
    else
        -- stylua: ignore
        return {
            LSIDE_FULL  = '',
            LSIDE_EMPTY = '|',
            RSIDE_FULL  = '',
            RSIDE_EMPTY = '|',
        }
    end
end

return {

    -- custom statusline
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

            -- empty space
            gls.left[1] = {
                EmptySpace1 = {
                    -- stylua: ignore
                    provider = function() return ' ' end,
                    highlight = 'StatusLineColor1',
                },
            }

            -- nvim mode
            gls.left[2] = {
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
            }

            -- empty space
            gls.left[3] = {
                EmptySpace2 = {
                    -- stylua: ignore
                    provider = function() return ' ' end,
                    highlight = 'StatusLineColor1',
                    separator = sep(opts.separator_style).LSIDE_FULL,
                    separator_highlight = 'StatusLineSeparator12',
                },
            }

            -- git branch
            gls.left[4] = {
                GitBranch = {
                    provider = 'GitBranch',
                    condition = condition.check_git_workspace,
                    icon = '  ',
                    highlight = 'StatusLineColor2',
                },
            }

            -- empty space
            gls.left[5] = {
                EmptySpace3 = {
                    -- stylua: ignore
                    provider = function() return ' ' end,
                    highlight = 'StatusLineColor2',
                    separator = sep(opts.separator_style).LSIDE_FULL,
                    separator_highlight = 'StatusLineSeparator23',
                },
            }

            -- diff add
            gls.left[6] = {
                DiffAdd = {
                    provider = 'DiffAdd',
                    condition = condition.check_git_workspace
                        and condition.hide_in_width,
                    icon = ' +',
                    highlight = 'StatusLineDiffAdd',
                },
            }

            -- diff delete
            gls.left[7] = {
                DiffRemove = {
                    provider = 'DiffRemove',
                    condition = condition.check_git_workspace
                        and condition.hide_in_width,
                    icon = ' -',
                    highlight = 'StatusLineDiffDelete',
                },
            }

            -- diff modified
            gls.left[8] = {
                DiffModified = {
                    provider = 'DiffModified',
                    condition = condition.check_git_workspace
                        and condition.hide_in_width,
                    icon = ' ~',
                    highlight = 'StatusLineDiffChange',
                },
            }

            --
            -- middle section
            --

            -- file name
            gls.mid[1] = {
                FilePath = {
                    provider = 'FilePath',
                    highlight = 'StatusLineColor3',
                },
            }

            -- buffer number
            gls.mid[2] = {
                BufferNumber = {
                    provider = 'BufferNumber',
                    highlight = 'StatusLineColor3',
                },
            }

            -- argument list
            gls.mid[3] = {
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
            }

            --
            -- right section
            --

            -- file encoding
            gls.right[1] = {
                FileEncoding = {
                    provider = 'FileEncode',
                    highlight = 'StatusLineColor3',
                    separator = sep(opts.separator_style).RSIDE_EMPTY,
                    separator_highlight = 'StatusLineSeparator23',
                },
            }

            -- empty space
            gls.right[2] = {
                EmptySpace4 = {
                    -- stylua: ignore
                    provider = function() return ' ' end,
                    highlight = 'StatusLineColor3',
                },
            }

            -- file type
            gls.right[3] = {
                FileType = {
                    provider = 'FileTypeName',
                    highlight = 'StatusLineColor3',
                    icon = ' ',
                    separator = sep(opts.separator_style).RSIDE_EMPTY,
                    separator_highlight = 'StatusLineSeparator23',
                },
            }

            -- empty space
            gls.right[4] = {
                EmptySpace4 = {
                    -- stylua: ignore
                    provider = function() return ' ' end,
                    highlight = 'StatusLineColor2',
                },
            }

            -- row and column
            gls.right[5] = {
                LineColumn = {
                    provider = 'LineColumn',
                    highlight = 'StatusLineColor2',
                    icon = ' ',
                    separator = sep(opts.separator_style).RSIDE_FULL,
                    separator_highlight = 'StatusLineSeparator23',
                },
            }

            -- line percentage of file
            gls.right[6] = {
                LinePercent = {
                    provider = 'LinePercent',
                    highlight = 'StatusLineColor2',
                    separator = sep(opts.separator_style).RSIDE_EMPTY,
                    separator_highlight = 'StatusLineColor2',
                },
            }
        end,
    },
}

-- vim: set tw=0 fo-=r ft=lua
