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

            local is_available = require('nvim-navic').is_available

            -- set up winbar
            if is_available then
                vim.o.winbar = "%{%v:lua.require('nvim-navic').get_location()%}"
            end
        end,
    },
}
