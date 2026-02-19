return {

    -- better formatters, overrides the lsp formatter
    {
        'stevearc/conform.nvim',
        opts = {
            formatters_by_ft = {
                -- note: these are installed via :Mason unless otherwise noted

                -- note: stylua doesn't always properly work in visual mode
                lua = { 'stylua', lsp_format = 'fallback' },

                -- ruff also runs in LSP mode as linter, but formatting is here
                -- ruff in LSP mode _does_ expose formatting imports, but as code actions
                python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports', lsp_format = 'fallback' },

                c = { 'clang-format', lsp_format = 'fallback' },
                cpp = { 'clang-format', lsp_format = 'fallback' },
                rust = { 'rustfmt' }, -- installed by the rust stack
                java = { 'google-java-format', lsp_format = 'fallback' },
                markdown = { 'mdformat', lsp_format = 'fallback' },
                latex = { 'tex-fmt' },
                tex = { 'tex-fmt' },
                bib = { 'tex-fmt' },
            },
        },
        config = function(_, opts)
            local conform = require('conform')
            conform.setup(opts)

            -- override lsp's default vim.lsp.buf.format()
            vim.keymap.set({ 'n', 'v' }, '<Leader>f', function()
                conform.format({ async = true })
            end, { desc = 'Format text (external tools override)' })
        end,
    },
}
