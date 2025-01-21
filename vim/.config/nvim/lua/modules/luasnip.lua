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
        opts = {
            -- keep around last snippet, if accidentally moving out of it
            keep_roots = true,
            link_roots = true,
            link_children = true,
            exit_roots = false,

            -- update snippets as you type
            update_events = { 'TextChanged', 'TextChangedI' },

            enable_autosnippets = true,

            -- ext_opts
        },
        config = function(_, opts)
            local ls = require('luasnip')

            -- snippet creator s(<trigger>, <nodes>)
            local s = ls.s

            -- format node fmt(<string>, { ...nodes })
            local fmt = require('luasnip.extras.fmt').fmt

            -- insert node i(<position>, [default_text])
            local i = ls.insert_node

            -- repeat node rep(<position>)
            local rep = require('luasnip.extras').rep

            -- snippet expand/jumps and change choice are mapped in
            -- lua/modules/nvim-cmp.lua as Tab/S-Tab/Ctrl-j/Ctrl-l
            ls.setup(opts)

            -- load vim-snippets
            require('luasnip.loaders.from_snipmate').lazy_load()

            -- other custom snippets here

            -- ls.add_snippets(<filetype>, { ...snippets })
            ls.add_snippets('all', {
                -- VSCode-style snippets
                -- ls.parser.parse_snippet('expand', 'expanded text!'),

                -- lua-style snippets
                -- s('expand twice', fmt('expand {} expand {}', { i(1), i(0) }))
            })

            ls.add_snippets('lua', {
                s('lreq', fmt("local {} = require('{}')", { i(1), i(0) })),
            })

            ls.add_snippets('markdown', {
                s(
                    'paper',
                    fmt('- ["{}" ({} et al. - {})]({}) - {}', {
                        i(1, 'Paper title'),
                        i(2, "Author's last name"),
                        i(3, 'Date published'),
                        i(4, 'URL'),
                        i(0, 'Description'),
                    })
                ),
            })
        end,
    },
}
