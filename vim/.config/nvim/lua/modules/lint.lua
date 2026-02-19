return {

    -- better linter support, additional context to lsp stuff
    {
        'mfussenegger/nvim-lint',
        config = function()
            require('lint').linters_by_ft = {

                lua = {},

                -- ruff runs as linter in LSP mode
                -- python = { 'ruff' },

                -- clang-tidy also runs, through clangd (clangd runs in LSP mode)
                c = { 'cppcheck' },

                markdown = { 'markdownlint-cli2' },
            }

            -- info on linters
            vim.api.nvim_create_user_command('LintInfo', function()
                vim.print(require('lint').get_running())
            end, {})

            -- run linters on file save
            vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
                callback = function()
                    require('lint').try_lint()
                end
            })
        end,
    },
}
