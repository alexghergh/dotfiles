-- set up completion kinds icons
local icons = {
    Class = '󰠱',
    Color = '󰏘',
    Constant = '󰏿',
    Constructor = '',
    Enum = '',
    EnumMember = '',
    Event = '',
    Field = '󰇽',
    File = '󰈙',
    Folder = '󰉋',
    Function = '󰊕',
    Interface = '',
    Keyword = '󰌋',
    Method = '󰆧',
    Module = '',
    Operator = '󰆕',
    Property = '󰜢',
    Reference = '',
    Snippet = '',
    Struct = '',
    Text = '',
    TypeParameter = '󰅲',
    Unit = '',
    Value = '󰎠',
    Variable = '󰂡',
}

return {

    -- sources for nvim-cmp
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-cmdline' },
    { 'hrsh7th/cmp-path' },
    { 'saadparwaiz1/cmp_luasnip' },

    -- auto-completion using nvim-cmp
    -- this plugin sets up the skeleton for accepting multiple sources, and the
    -- UI; sources need to be separately installed and set up
    --
    -- see :h nvim-cmp
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-path',
            'saadparwaiz1/cmp_luasnip',
            'L3MON4D3/LuaSnip',
        },
        opts = function(_, _)
            local cmp = require('cmp')
            local luasnip = require('luasnip')

            -- opts are unpacked in config()
            return {
                opts = {
                    mapping = cmp.mapping.preset.insert({
                        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                        ['<C-f>'] = cmp.mapping.scroll_docs(4),
                        ['<C-e>'] = cmp.mapping.abort(),
                        ['<CR>'] = cmp.mapping.confirm(),

                        -- luasnip snippets jump
                        ['<Tab>'] = cmp.mapping(function(fallback)
                            if luasnip.locally_jumpable(1) then
                                luasnip.jump(1)
                            else
                                fallback()
                            end
                        end, { 'i', 's' }),
                        ['<S-Tab>'] = cmp.mapping(function(fallback)
                            if luasnip.locally_jumpable(-1) then
                                luasnip.jump(-1)
                            else
                                fallback()
                            end
                        end, { 'i', 's' }),

                        -- quick expand (no Ctrl-n + CR) or jump forward
                        ['<C-j>'] = cmp.mapping(function(fallback)
                            if luasnip.expandable() then
                                luasnip.expand()
                            elseif luasnip.locally_jumpable(1) then
                                luasnip.jump(1)
                            else
                                fallback()
                            end
                        end, { 'i', 's' }),

                        -- "list" (i.e. change) choices; also works in normal mode
                        -- to open a telescope window with all the choices
                        -- (keymappped in lua/modules/luasnip.lua)
                        ['<C-l>'] = cmp.mapping(function(fallback)
                            if luasnip.choice_active() then
                                luasnip.change_choice(1)
                            else
                                fallback()
                            end
                        end, { 'i', 's' }),
                    }),
                    snippet = {
                        expand = function(args)
                            luasnip.lsp_expand(args.body)
                        end,
                    },
                    sources = {
                        { name = 'lazydev', group_index = 0 }, -- skip LuaLS completions
                        { name = 'nvim_lsp' },
                        { name = 'luasnip' },
                        { name = 'path' },
                        {
                            name = 'buffer',
                            option = {
                                get_bufnrs = function()
                                    -- complete from all buffers
                                    return vim.api.nvim_list_bufs()
                                end,
                            },
                            keyword_length = 3,
                        },
                    },
                    formatting = {
                        format = function(entry, vim_item)
                            vim_item.kind =
                                string.format('%s %s', icons[vim_item.kind], vim_item.kind)
                            vim_item.menu = ({
                                buffer = '[Buffer]',
                                path = '[Path]',
                                nvim_lsp = '[LSP]',
                                luasnip = '[Snip]',
                                nvim_lua = '[Lua]',
                                latex_symbols = '[LaTeX]',
                            })[entry.source.name]
                            return vim_item
                        end,
                    },
                    sorting = {
                        comparators = {
                            cmp.config.compare.exact,
                            cmp.config.compare.offset,
                            cmp.config.compare.score,
                            cmp.config.compare.recently_used,
                            cmp.config.compare.locality,
                            -- copied from lukas-reineke/cmp-under-comparator
                            function(entry1, entry2)
                                local _, entry1_under = entry1.completion_item.label:find('^_+')
                                local _, entry2_under = entry2.completion_item.label:find('^_+')
                                entry1_under = entry1_under or 0
                                entry2_under = entry2_under or 0
                                if entry1_under > entry2_under then
                                    return false
                                elseif entry1_under < entry2_under then
                                    return true
                                end
                            end,
                            cmp.config.compare.kind,
                            cmp.config.compare.sort_text,
                            cmp.config.compare.length,
                            cmp.config.compare.order,
                        },
                    },
                    experimental = {
                        ghost_text = true,
                    },
                    enabled = function()
                        local enabled = true

                        -- disable in comments
                        local context = require('cmp.config.context')
                        enabled = enabled
                            and not context.in_treesitter_capture('comment')
                            and not context.in_syntax_group('Comment')

                        -- disable in prompts
                        enabled = enabled
                            and not (
                                vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'prompt'
                            )

                        -- disable in macros
                        enabled = enabled and not (vim.fn.reg_recording() ~= '')
                        enabled = enabled and not (vim.fn.reg_executing() ~= '')

                        return enabled
                    end,
                },

                -- search (/, ?)
                opts_cmd_search = {
                    mapping = {
                        ['<C-n>'] = {
                            c = function(fallback)
                                if cmp.visible() then
                                    cmp.select_next_item()
                                else
                                    fallback()
                                end
                            end,
                        },
                        ['<C-p>'] = {
                            c = function(fallback)
                                if cmp.visible() then
                                    cmp.select_prev_item()
                                else
                                    fallback()
                                end
                            end,
                        },
                        ['<C-e>'] = { c = cmp.mapping.abort() },
                    },
                    sources = {
                        { name = 'buffer' },
                    },
                },

                -- command line (:)
                opts_cmd_command = {
                    mapping = {
                        ['<Tab>'] = {
                            c = function()
                                if cmp.visible() then
                                    cmp.select_next_item()
                                else
                                    cmp.complete()
                                end
                            end,
                        },
                        ['<S-Tab>'] = {
                            c = function()
                                if cmp.visible() then
                                    cmp.select_prev_item()
                                else
                                    cmp.complete()
                                end
                            end,
                        },
                        ['<C-n>'] = {
                            c = function(fallback)
                                if cmp.visible() then
                                    cmp.select_next_item()
                                else
                                    fallback()
                                end
                            end,
                        },
                        ['<C-p>'] = {
                            c = function(fallback)
                                if cmp.visible() then
                                    cmp.select_prev_item()
                                else
                                    fallback()
                                end
                            end,
                        },
                        ['<C-e>'] = {
                            c = cmp.mapping.abort(),
                        },
                        ['<C-f>'] = {
                            c = function(fallback)
                                cmp.close()
                                fallback()
                            end,
                        },
                        ['<CR>'] = {
                            c = function(fallback)
                                cmp.mapping.confirm()
                                fallback()
                            end,
                        },
                    },
                    sources = {
                        { name = 'path' },
                        { name = 'cmdline' },
                        { name = 'buffer' },
                    },
                },
            }
        end,
        config = function(_, opts)
            local cmp = require('cmp')

            -- setup general auto-completion
            cmp.setup(opts['opts'])

            -- setup cmdline auto-completion
            cmp.setup.cmdline({ '/', '?' }, opts['opts_cmd_search'])
            cmp.setup.cmdline(':', opts['opts_cmd_command'])
        end,
    },
}
