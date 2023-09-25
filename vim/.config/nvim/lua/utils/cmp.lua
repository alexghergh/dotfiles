--
-- auto-completion using nvim-cmp
-- this plugin only sets up the skeleton for accepting multiple sources
-- it also sets up the UI
--
-- sources need to be separately installed and set up
--
-- see :h nvim-cmp
--
local M = {}

if not pcall(require, 'cmp') then
    return nil
end

-- lsp source
if not pcall(require, 'cmp_nvim_lsp') then
    return nil
end

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
    return col ~= 0 and
        vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local cmp = require('cmp')
local luasnip = require('utils.luasnip').ls

-- setup general auto-completion
cmp.setup({
    enabled = function()
        -- disable in comments
        local context = require('cmp.config.context')
        if vim.api.nvim_get_mode().mode == 'c' then
            return true
        else
            return not context.in_treesitter_capture('comment')
                and not context.in_syntax_group('Comment')
        end
    end,
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end
    },
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
            elseif luasnip.choice_active() then
                luasnip.change_choice(1)
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<CR>'] = cmp.mapping.confirm(),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        {
            name = 'buffer',
            option = {
                get_bufnrs = function()
                    -- complete from all buffers
                    return vim.api.nvim_list_bufs()
                end
            }
        },
    }),
    formatting = {
        format = function(entry, vim_item)
            vim_item.kind = string.format('%s %s', icons[vim_item.kind], vim_item.kind)
            vim_item.menu = ({
                buffer = '[Buffer]',
                nvim_lsp = '[LSP]',
                luasnip = '[LuaSnip]',
                nvim_lua = '[Lua]',
                latex_symbols = '[LaTeX]',
            })[entry.source.name]
            return vim_item
        end
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
            end
        },
        ['<C-p>'] = {
            c = function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                else
                    fallback()
                end
            end
        },
        ['<C-e>'] = {
            c = cmp.mapping.abort()
        },
    },
    sources = {
        { name = 'buffer' }
    }
})

function M.default_capabilities(...)
    return require('cmp_nvim_lsp').default_capabilities(...)
end

return M
