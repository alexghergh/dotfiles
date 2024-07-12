return {

    -- snippets support

    -- see :h luasnip.txt
    -- see lua/modules/lspconfig.lua
    {
        'L3MON4D3/LuaSnip',
        dependencies = {
            'honza/vim-snippets',
        },
        config = function(_, opts)
            -- snippet expand/jumps and change choice are mapped in
            -- lua/modules/lspconfig.lua as Tab/S-Tab/Ctrl-e

            -- load vim-snippets
            require('luasnip.loaders.from_snipmate').lazy_load()
        end,
    }, --, tag = 'v2.*', run = 'make install_jsregexp' })

    { 'honza/vim-snippets' },
}

-- vim: set tw=0 fo-=r ft=lua
