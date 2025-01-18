return {

    -- snippets support

    -- see :h luasnip.txt
    -- see lua/modules/nvim-cmp.lua
    {
        'L3MON4D3/LuaSnip',
        tag = 'v2.*',
        run = 'make install_jsregexp',
        dependencies = {
            'honza/vim-snippets',
        },
        config = function(_, _)
            -- snippet expand/jumps and change choice are mapped in
            -- lua/modules/nvim-cmp.lua as Tab/S-Tab/Ctrl-e

            -- load vim-snippets
            require('luasnip.loaders.from_snipmate').lazy_load()
        end,
    },
}

-- vim: set tw=0 fo-=r ft=lua
