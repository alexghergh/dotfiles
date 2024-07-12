--
-- lsp servers setup
--
-- this includes setting up the lsp configs, as well as the auto-completion
-- engine managed by nvim-cmp, and any other off-spec lsp servers
--
-- see :h vim.lsp
-- see lua/core/lsp_client.lua
--

-- handlers overrides
local handlers = {
    -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization, 1st tip
    ['textDocument/hover'] = vim.lsp.with(
        vim.lsp.handlers.hover,
        { border = 'rounded' }
    ),
    ['textDocument/signatureHelp'] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        { border = 'rounded' }
    ),
}

-- lsp servers
local servers = {
    -- pacman ccls
    'ccls',

    -- pacman pyright
    'pyright',

    -- see ~/packages folder
    'jdtls',

    -- pacman lua-language-server
    'lua_ls',
}

return {

    -- neovim development lsp setup
    -- off spec lsp to assist in lua neovim configs
    -- sets up runtime dependencies for neovim stuff
    --
    -- see :h neodev
    {
        -- TODO replace with lazydev.nvim
        'folke/neodev.nvim',
        opts = {},
        dependencies = {
            'hrsh7th/nvim-cmp',
        },
    },

    -- neovim lsp server configs
    --
    -- see :h vim.lsp
    -- see :h lspconfig
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'hrsh7th/nvim-cmp',
            'hrsh7th/cmp-nvim-lsp',
            'folke/neodev.nvim',
        },
        opts = {},
        config = function(_, opts)
            -- border for :LspInfo
            require('lspconfig.ui.windows').default_options.border = 'rounded'

            -- setup the lsp servers
            for _, lsp in ipairs(servers) do
                require('lspconfig')[lsp].setup({
                    capabilities = require('cmp_nvim_lsp').default_capabilities(),
                    handlers = handlers,
                })
            end
        end,
    },

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
        },
        opts = {},
        config = function(_, opts)
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

            local function has_words_before()
                unpack = unpack or table.unpack
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0
                    and vim.api
                            .nvim_buf_get_lines(0, line - 1, line, true)[1]
                            :sub(col, col)
                            :match('%s')
                        == nil
            end

            local cmp = require('cmp')
            -- local luasnip = require('modules.luasnip').ls

            -- setup general auto-completion
            cmp.setup({
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
                            vim.api.nvim_buf_get_option(0, 'buftype')
                            == 'prompt'
                        )

                    -- disable in macros
                    enabled = enabled and not (vim.fn.reg_recording() ~= '')
                    enabled = enabled and not (vim.fn.reg_executing() ~= '')

                    return enabled
                end,
                -- snippet = {
                --     expand = function(args)
                --         require('luasnip').lsp_expand(args.body)
                --     end,
                -- },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-e>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.abort()
                        -- elseif luasnip.choice_active() then
                        --     luasnip.change_choice(1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<CR>'] = cmp.mapping.confirm(),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        -- elseif luasnip.expand_or_jumpable() then
                        --     luasnip.expand_or_jump()
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        -- elseif luasnip.jumpable(-1) then
                        --     luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    -- { name = 'luasnip' },
                }, {
                    {
                        name = 'buffer',
                        option = {
                            get_bufnrs = function()
                                -- complete from all buffers
                                return vim.api.nvim_list_bufs()
                            end,
                        },
                    },
                }),
                formatting = {
                    format = function(entry, vim_item)
                        vim_item.kind = string.format(
                            '%s %s',
                            icons[vim_item.kind],
                            vim_item.kind
                        )
                        vim_item.menu = ({
                            buffer = '[Buffer]',
                            nvim_lsp = '[LSP]',
                            -- luasnip = '[LuaSnip]',
                            nvim_lua = '[Lua]',
                            latex_symbols = '[LaTeX]',
                        })[entry.source.name]
                        return vim_item
                    end,
                },
                experimental = {
                    ghost_text = true,
                },
            })

            -- setup cmdline auto-completion
            cmp.setup.cmdline({ '/', '?' }, {
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
            })

            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline({
                    ['<C-f>'] = {
                        c = function(fallback)
                            cmp.close()
                            fallback()
                        end,
                    },
                    ['<CR>'] = { c = cmp.mapping.confirm() },
                }),
                sources = cmp.config.sources({
                    { name = 'path' },
                }, {
                    { name = 'cmdline' },
                }),
            })
        end,
    },

    -- sources for nvim-cmp
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-cmdline' },
    { 'hrsh7th/cmp-path' },
    { 'saadparwaiz1/cmp_luasnip' },
}

-- vim: set tw=0 fo-=r ft=lua
