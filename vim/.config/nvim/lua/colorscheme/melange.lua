M = {}

local function set_hl(...)
    vim.api.nvim_set_hl(0, ...)
end

function M.setup()
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
    set_hl(
        'CmpItemAbbrDeprecated',
        { fg = '#808080', bg = 'None', strikethrough = true }
    )
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
end

return M

-- vim: set tw=0 fo-=r ft=lua
