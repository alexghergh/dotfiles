M = {}

local function set_hl(...)
    vim.api.nvim_set_hl(0, ...)
end

function M.setup()
    -- background color for floats and statusline
    set_hl('NormalFloat', { fg = 'None', bg = 'None' })
    set_hl('FloatBorder', { fg = '#c5cdd9', bg = 'None' })
    set_hl('StatusLine', { bg = '#282c34' })

    -- diagnostic colors
    set_hl('DiagnosticLineNrError', { fg = '#ff0000', bg = '#51202a' })
    set_hl('DiagnosticLineNrWarn', { fg = '#ffa500', bg = '#51412a' })
    set_hl('DiagnosticLineNrInfo', { fg = '#00ffff', bg = '#1e535d' })
    set_hl('DiagnosticLineNrHint', { fg = '#0000ff', bg = '#1e205d' })

    -- statusline elements colors
    local statuslinecolor3_bg = '#282c34'
    set_hl('StatusLineColor1', { fg = '#3d4451', bg = '#8ab977', bold = true })
    set_hl('StatusLineColor2', { fg = '#a9a9af', bg = '#3e4452' })
    set_hl('StatusLineColor3', { fg = '#c2c2c2', bg = statuslinecolor3_bg })

    set_hl('StatusLineSeparator12', { fg = '#8ab977', bg = '#3d4451' })
    set_hl('StatusLineSeparator23', { fg = '#3e4452', bg = '#282c34' })

    -- statusline diff stats (added, removed, modified)
    set_hl('StatusLineDiffAdd', { fg = '#78997a', bg = statuslinecolor3_bg })
    set_hl('StatusLineDiffDelete', { fg = '#bd8183', bg = statuslinecolor3_bg })
    set_hl('StatusLineDiffChange', { fg = '#b380b0', bg = statuslinecolor3_bg })

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
    set_hl('LspReferenceRead', { bg = '#363331' })
    set_hl('LspReferenceText', { bg = '#363331' })
    set_hl('LspReferenceWrite', { bg = '#363331' })

    -- indentation guides
    set_hl('IblIndent', { fg = '#403c3b' })
    set_hl('IblScope', { fg = '#d2691e' })
end

return M
