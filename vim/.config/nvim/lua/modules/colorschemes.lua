--
-- colorscheme related setup + custom stuff (adjustments to existing
-- colorschemes) goes in here; that includes setting up colors / highlights

-- most of the custom stuff here is set up to be consistent with wezterm /
-- fish, or because the colorscheme doesn't support all the highlighting
-- groups of some of the plugins

-- see :h highlight
-- see :h colorscheme

local function set_hl(...)
    vim.api.nvim_set_hl(0, ...)
end

local function melange()
    -- floating windows
    set_hl('NormalFloat', { fg = 'None', bg = 'None' })
    set_hl('FloatBorder', { fg = '#c5cdd9', bg = 'None' })

    -- diagnostics
    set_hl('DiagnosticLineNrError', { fg = '#ff0000', bg = '#51202a' })
    set_hl('DiagnosticLineNrWarn', { fg = '#ffa500', bg = '#51412a' })
    set_hl('DiagnosticLineNrInfo', { fg = '#00ffff', bg = '#1e535d' })
    set_hl('DiagnosticLineNrHint', { fg = '#0000ff', bg = '#1e205d' })

    -- statusline
    local statusline_bg = '#282c34'
    set_hl('StatusLine', { bg = statusline_bg })

    set_hl('StatusLineColor1', { fg = '#3d4451', bg = '#8ab977', bold = true })
    set_hl('StatusLineColor2', { fg = '#a9a9af', bg = '#3e4452' })
    set_hl('StatusLineColor3', { fg = '#c2c2c2', bg = statusline_bg })

    set_hl('StatusLineSeparator12', { fg = '#8ab977', bg = '#3d4451' })
    set_hl('StatusLineSeparator23', { fg = '#3e4452', bg = statusline_bg })

    -- statusline diff stats (added, removed, modified)
    set_hl('StatusLineDiffAdd', { fg = '#78997a', bg = statusline_bg })
    set_hl('StatusLineDiffDelete', { fg = '#bd8183', bg = statusline_bg })
    set_hl('StatusLineDiffChange', { fg = '#b380b0', bg = statusline_bg })

    -- autocompletion menu items (nvim-cmp)
    -- gray
    set_hl('CmpItemAbbrDeprecated', { fg = '#808080', bg = 'None', strikethrough = true })
    -- blue
    set_hl('CmpItemAbbrMatch', { fg = '#569CD6', bg = 'None' })
    set_hl('CmpItemAbbrMatchFuzzy', { link = 'CmpIntemAbbrMatch' })
    -- light blue
    set_hl('CmpItemKindVariable', { fg = '#9CDCFE', bg = 'None' })
    set_hl('CmpItemKindInterface', { link = 'CmpItemKindVariable' })
    set_hl('CmpItemKindText', { link = 'CmpItemKindVariable' })
    -- pink
    set_hl('CmpItemKindFunction', { fg = '#C586C0', bg = 'None' })
    set_hl('CmpItemKindMethod', { link = 'CmpItemKindFunction' })
    -- front
    set_hl('CmpItemKindKeyword', { fg = '#D4D4D4', bg = 'None' })
    set_hl('CmpItemKindProperty', { link = 'CmpItemKindKeyword' })
    set_hl('CmpItemKindUnit', { link = 'CmpItemKindKeyword' })

    -- lsp (highlight symbol under cursor)
    set_hl('HighlightSymbol', { bg = '#4a4745' })
    set_hl('LspReferenceRead', { link = 'HighlightSymbol' })
    set_hl('LspReferenceText', { link = 'HighlightSymbol' })
    set_hl('LspReferenceWrite', { link = 'HighlightSymbol' })

    -- indentation guides
    set_hl('IblIndent', { fg = '#403c3b' })
    set_hl('IblScope', { fg = '#d2691e' })

    -- TODO luasnip, see tokyonight
end

local function tokyonight()
    local colors = require('lualine.themes._tokyonight').get()
    local normal = colors.normal.a

    -- statusline
    local statusline_bg = '#1a1c2a'
    set_hl('StatusLine', { bg = statusline_bg })

    set_hl('StatusLineColor1', { fg = normal.fg, bg = normal.bg, bold = true })
    set_hl('StatusLineColor2', { fg = '#c8d3f5', bg = '#3e4452' })
    set_hl('StatusLineColor3', { fg = '#c8d3f5', bg = statusline_bg })

    set_hl('StatusLineSeparator12', { fg = normal.bg, bg = '#3d4451' })
    set_hl('StatusLineSeparator23', { fg = '#3e4452', bg = statusline_bg })

    -- statusline diff stats (added, removed, modified)
    set_hl('StatusLineDiffAdd', { fg = normal.bg, bg = statusline_bg })
    set_hl('StatusLineDiffDelete', { fg = '#7f2530', bg = statusline_bg })
    set_hl('StatusLineDiffChange', { fg = '#6f4d99', bg = statusline_bg })

    -- LuaSnip
    set_hl('LuasnipInsertNodeActiveDot', { fg = '#86e1fc' })
    set_hl('LuasnipChoiceNodeActiveDot', { fg = '#ff966c' })

    -- CodeCompanion
    set_hl('CodeCompanionChatSeparator', { bg = '#b26a00' })
end

-- map colorscheme functions to strings
local colorscheme_functions = {
    ['melange'] = melange,
    ['tokyonight-moon'] = tokyonight,
    ['tokyonight-storm'] = tokyonight,
    ['tokyonight-night'] = tokyonight,
    ['tokyonight-day'] = tokyonight,
}

-- run on :colorscheme (re)load; make sure every function is named the same as
-- the colorscheme it represents (i.e. the custom colors/highlights associated
-- with 'melange' should be within a function called `melange()')
vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
        local status, _ = pcall(colorscheme_functions[vim.g.colors_name])
        if not status then
            vim.notify(
                'Colorscheme '
                    .. vim.g.colors_name
                    .. ' might not be correctly configured (see "colorschemes.lua").',
                vim.log.levels.WARN
            )
        end
    end,
    group = vim.api.nvim_create_augroup('_user_group', { clear = false }),
})

return {
    {
        'savq/melange-nvim',
        lazy = false, -- make sure we load this during startup if it is the main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            -- vim.cmd([[colorscheme melange]])
        end,
    },

    {
        'folke/tokyonight.nvim',
        lazy = false,
        priority = 1000,
        config = function(_, opts)
            table.insert(opts, {
                style = 'storm', -- 'night', 'moon', 'storm', 'day' <- this requires light background
            })
            require('tokyonight').setup(opts)

            vim.cmd([[colorscheme tokyonight]])
        end,
    },
}
