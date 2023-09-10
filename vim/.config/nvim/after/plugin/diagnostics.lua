-- diagnostics settings
-- see :h vim.diagnostic

-- diagnostics configuration
vim.diagnostic.config({
    virtual_text = {
        source = 'if_many',
        prefix = '● ',
    },
    float = {
        border = 'rounded',
        source = 'if_many'
    },
    update_in_insert = true,
    severity_sort = true,
})

-- display the diagnostic on curser hover
vim.api.nvim_create_autocmd('CursorHold', {
    buffer = bufnr,
    callback = function()
        local opts = {
            focusable = false,
            close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
            scope = 'cursor',
        }
        vim.diagnostic.open_float(nil, opts)
    end
})

-- only show the highest severity diagnostic gutter on any given line
-- see :h diagnostic-handlers-example
local ns = vim.api.nvim_create_namespace('_user_diagnostics_namespace')
local orig_signs_handler = vim.diagnostic.handlers.signs
vim.diagnostic.handlers.signs = {
    show = function(_, bufnr, _, opts)
        -- get all the diagnostics in the buffer, rather than just those passed
        -- in to the function
        local diagnostics = vim.diagnostic.get(bufnr)

        -- find the highest severity diagnostic per line
        local max_severity_per_line = {}
        for _,d in pairs(diagnostics) do
            local m = max_severity_per_line[d.lnum]
            if not m or d.severity < m.severity then
                max_severity_per_line[d.lnum] = d
            end
        end

        -- pass the filtered diagnostics to the original handler
        local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
        orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
    end,
    hide = function(_, bufnr)
        orig_signs_handler.hide(ns, bufnr)
    end,
}

-- diagnostic gutter signs
local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- highlight line number instead of having icons in gutter for diagnostics
-- (for now keep the signs, but delete if unnecessary/annoying)
vim.cmd [[
    highlight! DiagnosticLineNrError guibg=#51202A guifg=#FF0000 gui=bold
    highlight! DiagnosticLineNrWarn guibg=#51412A guifg=#FFA500 gui=bold
    highlight! DiagnosticLineNrInfo guibg=#1E535D guifg=#00FFFF gui=bold
    highlight! DiagnosticLineNrHint guibg=#1E205D guifg=#0000FF gui=bold

    sign define DiagnosticSignError text=  texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
    sign define DiagnosticSignWarn text=  texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
    sign define DiagnosticSignInfo text=  texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
    sign define DiagnosticSignHint text=  texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint

    " TODO find a way to get these underline colors working; right now they don't
    " seem to do anything at all and my best guess is that tmux might be
    " interfering in some way, as undercurls (curly underlines) also don't work
    " and revert back to simple underlines in tmux, but otherwise work fine
    " outside of it
    " highlight! DiagnosticUnderlineError guifg=#51202A guibg=#FF0000 gui=bold
    " highlight! DiagnosticUnderlineWarn cterm=undercurl gui=undercurl guisp=#ff00ff
    " highlight! DiagnosticUnderlineInfo cterm=undercurl gui=undercurl guisp=#00ff00
    " highlight! diagnosticunderlinehint guifg=#1e205d guibg=#0000ff gui=bold
]]
