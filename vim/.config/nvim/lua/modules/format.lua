return {

    -- better formatters, overrides the lsp formatter
    'stevearc/conform.nvim',
    opts = {
        formatters_by_ft = {
            -- note: these are installed via :Mason, make sure to have them installed automatically

            -- stylua runs in LSP mode (range formatting doesn't properly work on the CLI)
            lua = { 'stylua', lsp_format = 'prefer' },

            python = { 'ruff_organize_imports', 'ruff_fix', 'ruff_format' },
            c = { 'clang-format', lsp_format = 'fallback' },
            cpp = { 'clang-format', lsp_format = 'fallback' },
            rust = { 'rustfmt' }, -- installed by the rust stack
            java = { 'google-java-format', lsp_format = 'fallback' },
            markdown = { 'markdown-lint' },
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
}
