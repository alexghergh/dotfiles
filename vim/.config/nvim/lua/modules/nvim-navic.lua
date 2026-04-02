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

            -- set up winbar
            vim.o.winbar = "%{%v:lua.require('nvim-navic').is_available() ? v:lua.require('nvim-navic').get_location() : ''%}"
        end,
    },
}
