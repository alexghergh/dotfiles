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

-- custom comparators
local cmp_under_comparator = function(entry1, entry2)
    local _, entry1_under = entry1.completion_item.label:find('^_+')
    local _, entry2_under = entry2.completion_item.label:find('^_+')
    entry1_under = entry1_under or 0
    entry2_under = entry2_under or 0
    if entry1_under > entry2_under then
        return false
    elseif entry1_under < entry2_under then
        return true
    end
end

-- see https://github.com/hrsh7th/nvim-cmp/issues/156
local cmp_lspkind = (function(conf)
    local lsp_types = require('cmp.types').lsp
    return function(entry1, entry2)
        if entry1.source.name ~= 'nvim_lsp' then
            if entry2.source.name == 'nvim_lsp' then
                return false
            else
                return nil
            end
        end
        local kind1 = lsp_types.CompletionItemKind[entry1:get_kind()]
        local kind2 = lsp_types.CompletionItemKind[entry2:get_kind()]

        local priority1 = conf.kind_priority[kind1] or 0
        local priority2 = conf.kind_priority[kind2] or 0
        if priority1 == priority2 then
            return nil
        end
        return priority2 < priority1
    end
end)({
    kind_priority = {
        Field = 11,
        Property = 11,
        Constant = 10,
        Enum = 10,
        EnumMember = 10,
        Event = 10,
        Function = 10,
        Method = 10,
        Operator = 10,
        Reference = 10,
        Struct = 10,
        Variable = 9,
        File = 8,
        Folder = 8,
        Class = 5,
        Color = 5,
        Module = 5,
        Keyword = 2,
        Constructor = 1,
        Interface = 1,
        Snippet = 0,
        Text = 1,
        TypeParameter = 1,
        Unit = 1,
        Value = 1,
    },
})

return {

    -- auto-completion using nvim-cmp
    -- this plugin sets up the skeleton for accepting multiple sources, and the
    -- UI; sources need to be separately installed and set up
    --
    -- see :h nvim-cmp
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- sources for nvim-cmp
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
                insert = {
                    mapping = cmp.mapping.preset.insert({
                        ['<C-u>'] = {
                            i = function(fallback)
                                if cmp.visible() then
                                    cmp.select_prev_item({ count = 12 })
                                else
                                    fallback()
                                end
                            end,
                        },
                        ['<C-d>'] = {
                            i = function(fallback)
                                if cmp.visible() then
                                    cmp.select_next_item({ count = 12 })
                                else
                                    fallback()
                                end
                            end,
                        },
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
                        {
                            name = 'path',
                            entry_filter = function(_, ctx)
                                local token = ctx.cursor_before_line:match('%S+$') or ''
                                local is_path = token:match('^/')
                                    or token:match('^%./')
                                    or token:match('^%.%./')
                                    or token:match('^~/')
                                    or token:match('^%$[%a_][%w_]*/')
                                    or token:match('^[^%s]+/')
                                return is_path ~= nil
                            end,
                        },
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
                            vim_item.kind = string.format('%s %s', icons[vim_item.kind], vim_item.kind)
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
                            cmp_under_comparator,
                            -- cmp.config.compare.kind, -- see custom kind comparator below
                            cmp_lspkind,
                            cmp.config.compare.sort_text,
                            cmp.config.compare.length,
                            cmp.config.compare.order,
                        },
                    },
                    experimental = {
                        ghost_text = true,
                    },
                    enabled = function()
                        local context = require('cmp.config.context')

                        -- stylua: ignore
                        return
                            -- disable in comments
                            not context.in_treesitter_capture('comment')
                            and not context.in_syntax_group('Comment')

                            -- disable in prompts
                            and vim.api.nvim_get_option_value('buftype', { buf = 0 }) ~= 'prompt'
                            and vim.bo.filetype ~= 'namu_prompt'

                            -- disable in macros
                            and vim.fn.reg_recording() == ''
                            and vim.fn.reg_executing() == ''
                    end,
                },

                -- search (/, ?)
                search = {
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
                command = {
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
                                -- since we get a completion window shown, and <C-n> and <C-p> fill the
                                -- command line with the command anyway, pressing enter should just
                                -- trigger the filled-in command; otherwise, you'd have to press <CR>
                                -- twice (once to accept the cmp entry, one to actually execute it)
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
            cmp.setup(opts.insert)

            -- setup cmdline auto-completion
            cmp.setup.cmdline({ '/', '?' }, opts.search)
            cmp.setup.cmdline(':', opts.command)

            -- autopairs on function / method insert (skip codecompanion slash commands, which are also Function item kind)
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local on_confirm_done = cmp_autopairs.on_confirm_done()
            cmp.event:on('confirm_done', function(evt)
                if evt.entry.source.name == 'codecompanion_acp_commands' or evt.entry.source.name == 'codecompanion_slash_commands' then
                    return
                end
                on_confirm_done(evt)
            end)
        end,
    },
}
