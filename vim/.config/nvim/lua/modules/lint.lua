-- see lua/shared/tooling.lua for linter definitions
local tooling = require('shared.tooling')

-- nvim-lint-specific per-linter overrides
local linter_opts = {
    -- examples:
    -- cppcheck = {
    --     args = { '--enable=warning,style,performance,portability', '--template=gcc', '--quiet' },
    -- },
    -- markdownlint-cli2 = {
    --     args = { '--config', vim.fn.expand('~/.markdownlint-cli2.yaml') },
    -- },
}

local function apply_linter_opts(lint, overrides)
    for name, opts in pairs(overrides) do
        local linter = lint.linters[name]

        if linter ~= nil then
            lint.linters[name] = vim.tbl_deep_extend('force', linter, opts)
        end
    end
end

return {

    -- better linter support, additional context to lsp stuff
    {
        'mfussenegger/nvim-lint',
        config = function()
            local lint = require('lint')

            lint.linters_by_ft = tooling.linters_by_ft()
            apply_linter_opts(lint, linter_opts)

            -- linters information
            vim.api.nvim_create_user_command('LintInfo', function()
                vim.print(lint.get_running())
            end, {})

            vim.keymap.set('n', '<Leader>il', ':LintInfo<CR>', { desc = 'Linters information' })

            -- run linters on file save
            vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
    },
}
