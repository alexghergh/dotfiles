--
-- colorscheme related setup + custom stuff (adjustments to existing
-- colorschemes) goes in here; that includes setting up colors / highlights

-- most of the custom stuff here is set up to be consistent with wezterm /
-- fish, or because the colorscheme doesn't support all the highlighting
-- groups of some of the plugins

-- see :h highlight
-- see :h colorscheme

local function _colorscheme_defaults()
    return {
        -- LuaSnip
        ['LuasnipInsertNodeActiveDot'] = { fg = '#86e1fc' },
        ['LuasnipChoiceNodeActiveDot'] = { fg = '#ff966c' },

        -- CodeCompanion
        ['CodeCompanionChatSeparator'] = { bg = '#b26a00' },

        -- lightbulb code actions
        ['LightBulbVirtualText'] = { fg = '#ffc777' },
    }
end

local function melange()
    local statusline_bg = '#282c34'

    return {
        -- floating windows
        ['NormalFloat'] = { fg = 'None', bg = 'None' },
        ['FloatBorder'] = { fg = '#c5cdd9', bg = 'None' },

        -- diagnostics
        ['DiagnosticLineNrError'] = { fg = '#ff0000', bg = '#51202a' },
        ['DiagnosticLineNrWarn'] = { fg = '#ffa500', bg = '#51412a' },
        ['DiagnosticLineNrInfo'] = { fg = '#00ffff', bg = '#1e535d' },
        ['DiagnosticLineNrHint'] = { fg = '#0000ff', bg = '#1e205d' },

        -- statusline
        ['StatusLine'] = { bg = statusline_bg },

        ['StatusLineColor1'] = { fg = '#3d4451', bg = '#8ab977', bold = true },
        ['StatusLineColor2'] = { fg = '#a9a9af', bg = '#3e4452' },
        ['StatusLineColor3'] = { fg = '#c2c2c2', bg = statusline_bg },

        ['StatusLineSeparator12'] = { fg = '#8ab977', bg = '#3d4451' },
        ['StatusLineSeparator23'] = { fg = '#3e4452', bg = statusline_bg },

        -- statusline diff stats (added, removed, modified)
        ['StatusLineDiffAdd'] = { fg = '#78997a', bg = statusline_bg },
        ['StatusLineDiffDelete'] = { fg = '#bd8183', bg = statusline_bg },
        ['StatusLineDiffChange'] = { fg = '#b380b0', bg = statusline_bg },

        -- autocompletion menu items (nvim-cmp)
        -- gray
        ['CmpItemAbbrDeprecated'] = { fg = '#808080', bg = 'None', strikethrough = true },
        -- blue
        ['CmpItemAbbrMatch'] = { fg = '#569CD6', bg = 'None' },
        ['CmpItemAbbrMatchFuzzy'] = { link = 'CmpIntemAbbrMatch' },
        -- light blue
        ['CmpItemKindVariable'] = { fg = '#9CDCFE', bg = 'None' },
        ['CmpItemKindInterface'] = { link = 'CmpItemKindVariable' },
        ['CmpItemKindText'] = { link = 'CmpItemKindVariable' },
        -- pink
        ['CmpItemKindFunction'] = { fg = '#C586C0', bg = 'None' },
        ['CmpItemKindMethod'] = { link = 'CmpItemKindFunction' },
        -- front
        ['CmpItemKindKeyword'] = { fg = '#D4D4D4', bg = 'None' },
        ['CmpItemKindProperty'] = { link = 'CmpItemKindKeyword' },
        ['CmpItemKindUnit'] = { link = 'CmpItemKindKeyword' },

        -- lsp (highlight symbol under cursor)
        ['HighlightSymbol'] = { bg = '#4a4745' },
        ['LspReferenceRead'] = { link = 'HighlightSymbol' },
        ['LspReferenceText'] = { link = 'HighlightSymbol' },
        ['LspReferenceWrite'] = { link = 'HighlightSymbol' },

        -- indentation guides
        ['IblIndent'] = { fg = '#403c3b' },
        ['IblScope'] = { fg = '#d2691e' },
    }
end

local function tokyonight()
    local colors = require('lualine.themes._tokyonight').get()
    local normal = colors.normal.a
    local statusline_bg = '#1a1c2a'

    -- statusline
    return {
        ['StatusLine'] = { bg = statusline_bg },

        ['StatusLineColor1'] = { fg = normal.fg, bg = normal.bg, bold = true },
        ['StatusLineColor2'] = { fg = '#c8d3f5', bg = '#3e4452' },
        ['StatusLineColor3'] = { fg = '#c8d3f5', bg = statusline_bg },

        ['StatusLineSeparator12'] = { fg = normal.bg, bg = '#3d4451' },
        ['StatusLineSeparator23'] = { fg = '#3e4452', bg = statusline_bg },

        -- statusline diff stats (added, removed, modified)
        ['StatusLineDiffAdd'] = { fg = normal.bg, bg = statusline_bg },
        ['StatusLineDiffDelete'] = { fg = '#7f2530', bg = statusline_bg },
        ['StatusLineDiffChange'] = { fg = '#6f4d99', bg = statusline_bg },
    }
end

-- map colorscheme functions to strings; every function should be named the same
-- as the colorscheme it represents
local _colorscheme_functions_table = {
    ['melange'] = melange,
    ['tokyonight-moon'] = tokyonight,
    ['tokyonight-storm'] = tokyonight,
    ['tokyonight-night'] = tokyonight,
    ['tokyonight-day'] = tokyonight,
}

-- run on :colorscheme (re)load
vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
        local match = vim.g.colors_name -- args.match doesn't exactly work

        -- get defaults shared among colorschemes
        local spec = _colorscheme_defaults()

        -- apply colorscheme specific stuff
        local cs_func = _colorscheme_functions_table[match]
        if cs_func ~= nil then
            spec = vim.tbl_deep_extend('force', spec, cs_func())
            for hi, opts in pairs(spec) do
                vim.api.nvim_set_hl(0, hi, opts)
            end
            vim.schedule(function()
                vim.notify("Set colorscheme to '" .. match .. "'", vim.log.levels.INFO)
            end)
        else
            vim.schedule(function()
                vim.notify("Colorscheme '" .. match .. "' is not correctly configured (see 'colorschemes.lua').", vim.log.levels.ERROR)
            end)
        end
    end,
    group = vim.api.nvim_create_augroup('_user_group', { clear = false }),
})

return {
    {
        'savq/melange-nvim',
        lazy = false, -- don't load plugin unless this colorscheme is used
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            -- vim.cmd.colorscheme('melange')
        end,
    },

    {
        'folke/tokyonight.nvim',
        lazy = false,
        priority = 1000,
        opts = {
            style = 'moon', -- 'night', 'moon', 'storm', 'day' <- this requires light background
        },
        config = function(_, opts)
            require('tokyonight').setup(opts)
            vim.cmd.colorscheme('tokyonight')
        end,
    },
}
