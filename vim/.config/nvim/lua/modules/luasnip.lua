return {

    -- snippets support

    -- see :h luasnip.txt
    -- see lua/modules/nvim-cmp.lua
    -- see lua/snippets/<ft>.lua
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
        },
        config = function(_, opts)
            local ls = require('luasnip')
            local types = require('luasnip.util.types')

            -- virtual text opts (highlight groups are defined in
            -- lua/modules/colorschemes.lua, per colorscheme)
            opts['ext_opts'] = {
                [types.insertNode] = {
                    active = {
                        virt_text = { { '●', 'LuasnipInsertNodeActiveDot' } },
                    },
                },
                [types.choiceNode] = {
                    active = {
                        virt_text = { { '●', 'LuasnipChoiceNodeActiveDot' } },
                    },
                },
            }

            -- snippet expand/jumps and change choice keymaps can be found in
            -- lua/modules/nvim-cmp.lua as Tab/S-Tab/Ctrl-j/Ctrl-l
            ls.setup(opts)

            -- load vim-snippets
            require('luasnip.loaders.from_snipmate').lazy_load()

            -- load custom snippets (see lua/snippets/<ft>.lua)
            require('luasnip.loaders.from_lua').load({
                paths = '~/.config/nvim/lua/snippets',
            })

            -- select_choice with vim.ui.select (Ctrl-l in insert mode mapped in
            -- lua/modules/nvim-cmp.lua; this keymap is normal mode for choice)
            vim.keymap.set(
                'n',
                '<Leader><C-l>',
                require('luasnip.extras.select_choice')
            )

            -- edit snippets
            vim.keymap.set(
                'n',
                '<Leader><Leader>s',
                require('luasnip.loaders').edit_snippet_files
            )
        end,
    },
}
