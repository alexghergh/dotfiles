--
-- diagnostics settings
--
-- see :h vim.diagnostic
-- see lua/colorscheme/*.lua - colors for the diagnostics signs
-- see lua/core/keymaps.lua - diagnostic keymaps
--

-- diagnostics configuration
vim.diagnostic.config({
    virtual_text = {
        source = 'if_many',
        prefix = '● ',
        spacing = 15,
    },
    float = {
        border = 'rounded',
        source = 'if_many',
    },
    severity_sort = true,
})

-- display the diagnostic on curser hover
vim.api.nvim_create_autocmd('CursorHold', {
    buffer = bufnr,
    callback = function()
        local opts = {
            focusable = false,
            close_events = {
                'BufLeave',
                'CursorMoved',
                'InsertEnter',
                'FocusLost',
            },
            scope = 'cursor',
        }
        vim.diagnostic.open_float(nil, opts)
    end,
})

-- only show the highest severity diagnostic gutter sign on any given line
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
        for _, d in pairs(diagnostics) do
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

-- diagnostic gutter signs and line number highlight
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
            [vim.diagnostic.severity.INFO] = ' ',
        },
        texthl = {
            -- see lua/modules/colorschemes.lua
            [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
            [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarm',
            [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
            [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
        },
        numhl = {
            -- see lua/modules/colorschemes.lua
            [vim.diagnostic.severity.ERROR] = 'DiagnosticLineNrError',
            [vim.diagnostic.severity.WARN] = 'DiagnosticLineNrWarm',
            [vim.diagnostic.severity.HINT] = 'DiagnosticLineNrHint',
            [vim.diagnostic.severity.INFO] = 'DiagnosticLineNrInfo',
        },
    },
    virtual_text = true,
    update_in_insert = true,
    severity_sort = true,
})
