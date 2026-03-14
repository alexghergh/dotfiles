-- see lua/shared/tooling.lua for formatter definitions
local tooling = require('shared.tooling')

-- specific conform.nvim per-filetype options
local format_opts_by_ft = {
    -- examples:
    -- lua = { lsp_format = 'fallback' },
}

-- specific conform.nvim per-formatter overrides
local formatter_opts = {
    -- examples:
    -- stylua = {
    --     prepend_args = { '--indent-type', 'Spaces' },
    -- },
    -- yamlfmt = {
    --     prepend_args = { '-formatter', 'indent=2' },
    -- },
}

local function merge_ft_opts(base, overrides)
    local out = vim.deepcopy(base)

    for ft, opts in pairs(overrides) do
        out[ft] = out[ft] or {}

        for key, value in pairs(opts) do
            out[ft][key] = value
        end
    end

    return out
end

return {

    -- better formatters, overrides the lsp formatter
    {
        'stevearc/conform.nvim',
        opts = {
            formatters_by_ft = merge_ft_opts(tooling.formatters_by_ft(), format_opts_by_ft),
            formatters = formatter_opts,
        },
        config = function(_, opts)
            local conform = require('conform')
            conform.setup(opts)

            -- override lsp's default vim.lsp.buf.format()
            vim.keymap.set({ 'n', 'v' }, '<Leader>f', function()
                conform.format({ async = true, lsp_format = 'fallback' })
            end, { desc = 'Format text (external formatters override)' })

            -- formatters information
            vim.keymap.set('n', '<Leader>if', ':ConformInfo<CR>', { desc = 'Formatters information' })
        end,
    },
}
