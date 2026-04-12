return {

    -- cursor scope
    {
        'SmiteshP/nvim-navic',
        opts = {
            lsp = {
                auto_attach = true,
            },
        },
        dependencies = {
            'neovim/nvim-lspconfig',
        },
        config = function(_, opts)
            require('nvim-navic').setup(opts)

            -- navic is consumed from incline, so we don't set any winbar here
            -- see lua/modules/statusline.lua

            -- large files don't need breadcrumb updates on every cursor move; defer it
            vim.api.nvim_create_autocmd('BufEnter', {
                callback = function(args)
                    if vim.api.nvim_buf_line_count(args.buf) > 10000 then
                        vim.b[args.buf].navic_lazy_update_context = true
                    end
                end,
                group = vim.api.nvim_create_augroup('_user_group', { clear = false }),
            })
        end,
    },
}
