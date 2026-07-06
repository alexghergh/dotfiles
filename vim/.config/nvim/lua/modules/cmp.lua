--
-- completion engine setup
--

-- auto-open blink menu when entering a snippets choice node; these appear in the completion menu
vim.api.nvim_create_autocmd('User', {
    pattern = 'LuasnipChoiceNodeEnter',
    callback = function()
        vim.schedule(function()
            require('blink.cmp').show({ providers = { 'snippets' } })
        end)
    end,
})

-- render LuaSnip's docstring as readable text:
--   ${N:content}  -> {content}   (tabstop default shown as wrapped placeholder)
--   ${content}    -> content     (node-wrap, stripped)
-- LuaSnip (wrongly) doesn't escape literal braces in docstrings so we depth-count to find each matching
-- close rather than relying on brace-free content classes; recurses to handle nesting to arbitrary depth
local function unwrap_docstring(s)
    local out = {}
    local i, n = 1, #s
    while i <= n do
        if s:sub(i, i) == '$' and s:sub(i + 1, i + 1) == '{' then
            local depth, j = 1, i + 2
            while j <= n and depth > 0 do
                local ch = s:sub(j, j)
                if ch == '{' then
                    depth = depth + 1
                elseif ch == '}' then
                    depth = depth - 1
                end
                if depth == 0 then
                    break
                end
                j = j + 1
            end
            if depth == 0 then
                local body = s:sub(i + 2, j - 1)
                local numbered = body:match('^%d+:(.*)$')
                if numbered then
                    table.insert(out, '{' .. unwrap_docstring(numbered) .. '}')
                else
                    table.insert(out, unwrap_docstring(body))
                end
                i = j + 1
            else
                -- unmatched ${ — treat literally so we never lose input
                table.insert(out, s:sub(i, i))
                i = i + 1
            end
        else
            table.insert(out, s:sub(i, i))
            i = i + 1
        end
    end
    return table.concat(out)
end

return {
    {
        -- blink self-injects LSP completion capabilities at startup, by calling:
        --
        --   vim.lsp.config('*', { capabilities = blink.get_lsp_capabilities() }))
        --
        'saghen/blink.cmp',
        dependencies = {
            'saghen/blink.lib', -- utils
            'L3MON4D3/LuaSnip', -- snippets
            -- completion sources
            'Kaiser-Yang/blink-cmp-git',
            'delphinus/cmp-wezterm',
            'mikavilpas/blink-ripgrep.nvim',
        },
        build = function()
            require('blink.cmp').build():pwait()
        end,
        opts = {
            enabled = function()
                -- disable in macros
                if vim.fn.reg_recording() ~= '' or vim.fn.reg_executing() ~= '' then
                    return false
                end

                -- disable in prompts
                if vim.bo.buftype == 'prompt' then
                    return false
                end

                -- disable if completion is not enabled
                return vim.b.completion ~= false
            end,

            snippets = {
                preset = 'luasnip',
            },

            completion = {

                -- fuzzy match on text from both before and after the cursor
                keyword = {
                    range = 'full',
                },

                trigger = {
                    -- see https://main.cmp.saghen.dev/configuration/reference.html#completion-trigger for defaults
                },

                -- don't auto-select; insert text in buffer on selection
                list = {
                    selection = {
                        preselect = false,
                        auto_insert = true,
                    },
                },

                accept = {
                    auto_brackets = {
                        -- ignore codecompanion slash commands (don't add () after those; CodeCompanion registers them as function kinds)
                        blocked_filetypes = { 'codecompanion', 'codecompanion_input' },
                    },
                },

                menu = {
                    draw = {
                        gap = 2,
                        treesitter = { 'lsp' }, -- highlight items in the completion menu using treesitter
                        columns = {
                            { 'label', 'label_description', gap = 2 },
                            { 'kind_icon', 'kind', gap = 1 },
                            { 'source_name' },
                        },
                        components = {
                            source_name = {
                                highlight = 'Comment',
                            },
                        },
                    },

                    -- on multi-line ghost text, prevent the completion menu from overlapping with the text
                    direction_priority = function()
                        local ctx = require('blink.cmp').get_context()
                        local item = require('blink.cmp').get_selected_item()
                        if ctx == nil or item == nil then
                            return { 's', 'n' }
                        end

                        local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
                        local is_multi_line = item_text:find('\n') ~= nil

                        -- after showing the menu upwards, we want to maintain that direction
                        -- until we re-open the menu, so store the context id in a global variable
                        if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
                            vim.g.blink_cmp_upwards_ctx_id = ctx.id
                            return { 'n', 's' }
                        end
                        return { 's', 'n' }
                    end,
                },

                -- show documentation when selecting a completion item
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 100,
                },

                ghost_text = {
                    enabled = true,
                },
            },

            signature = {
                enabled = true,
            },

            -- improved fuzzy matching implementation
            fuzzy = {
                implementation = 'prefer_rust_with_warning',
            },

            sources = {
                default = function()
                    local success, node = pcall(vim.treesitter.get_node)

                    -- in comments, only completion from buffers; otherwise full sources
                    if success and node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
                        return { 'buffer' }
                    else
                        return {
                            'lsp',
                            'path',
                            'snippets',
                            'buffer',
                            'lazydev',
                            'git',
                            'wezterm',
                            'ripgrep',
                        }
                    end
                end,
                providers = {
                    lsp = {
                        -- this defaults to 'buffer'; always show both lsp and buffer
                        fallbacks = {},
                    },
                    lazydev = {
                        module = 'lazydev.integrations.blink',
                        score_offset = 100,
                    },
                    buffer = {
                        min_keyword_length = 3,
                        opts = {
                            get_bufnrs = function()
                                return vim.tbl_filter(function(bufnr)
                                    return vim.bo[bufnr].buftype == ''
                                end, vim.api.nvim_list_bufs())
                            end,
                        },
                    },
                    snippets = {
                        -- work-around for luasnip choice nodes: they don't return a fully expanded description, so all items look identical
                        -- in the completion menu; enrich each via the choice's own get_docstring() (rendered via unwrap_docstring() above)
                        transform_items = function(ctx, items)
                            local luasnip = require('luasnip')
                            if not luasnip.choice_active() then
                                return items
                            end
                            local active = luasnip.session.active_choice_nodes[ctx.bufnr]
                            if not active then
                                return items
                            end
                            pcall(function()
                                active:update_static_all()
                            end)

                            for _, item in ipairs(items) do
                                if item.data and item.data.choice_index then
                                    local choice = active.choices[item.data.choice_index]
                                    if choice then
                                        local ok, doc = pcall(function()
                                            return choice:get_docstring()
                                        end)
                                        if ok and doc then
                                            local raw = type(doc) == 'table' and table.concat(doc, '\n') or tostring(doc)
                                            local text = unwrap_docstring(raw)
                                            local first_line = (text:match('^([^\n]*)') or ''):gsub('^%s+', '')
                                            if first_line ~= '' then
                                                item.label = first_line
                                                item.insertText = text
                                            end
                                            item.documentation = { kind = 'markdown', value = '```\n' .. text .. '\n```' }
                                        end
                                    end
                                end
                            end
                            return items
                        end,
                    },
                    git = {
                        name = 'Git',
                        module = 'blink-cmp-git',
                        -- only fire in commit-like contexts
                        enabled = function()
                            return vim.tbl_contains({ 'octo', 'gitcommit', 'markdown' }, vim.bo.filetype)
                        end,
                    },
                    wezterm = {
                        name = 'wezterm',
                        module = 'blink-cmp-wezterm',
                        async = true,
                        -- only fire in commit-like contexts
                        enabled = function()
                            return vim.bo.filetype == 'gitcommit'
                        end,
                        -- strip labelDetails.detail (wezterm's win:tab:paneid) so it doesn't show in the completion menu
                        transform_items = function(_, items)
                            for _, item in ipairs(items) do
                                item.labelDetails = nil
                            end
                            return items
                        end,
                    },
                    ripgrep = {
                        name = 'Ripgrep',
                        module = 'blink-ripgrep',
                    },
                },
            },

            -- insert / select modes
            keymap = {
                preset = 'default',
                ['<C-u>'] = {
                    function(cmp)
                        if cmp.is_visible() then
                            return cmp.select_prev({ count = 12 })
                        end
                    end,

                    'fallback',
                },
                ['<C-d>'] = {
                    function(cmp)
                        if cmp.is_visible() then
                            return cmp.select_next({ count = 12 })
                        end
                    end,
                    'fallback',
                },
                ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
                ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
                ['<C-e>'] = { 'cancel', 'fallback' },
                ['<CR>'] = { 'accept', 'fallback' },
                ['<C-n>'] = { 'show', 'select_next', 'fallback' },
                ['<C-p>'] = { 'show', 'select_prev', 'fallback' },

                -- snippet navigation
                ['<Tab>'] = { 'snippet_forward', 'fallback' },
                ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

                -- cycle luasnip choices; normal-mode <Leader><C-l> uses vim.ui.select (see lua/modules/snippets.lua)
                ['<C-l>'] = {
                    function()
                        local luasnip = require('luasnip')
                        if luasnip.choice_active() then
                            luasnip.change_choice(1)
                            return true
                        end
                    end,
                    'fallback',
                },
            },

            -- command-line / search modes
            cmdline = {
                completion = {
                    menu = {
                        auto_show = true,
                    },
                },
                keymap = {
                    preset = 'cmdline',
                    ['<Tab>'] = { 'show_and_insert_or_accept_single', 'select_next', 'fallback' },
                    ['<S-Tab>'] = { 'show_and_insert_or_accept_single', 'select_prev', 'fallback' },
                    ['<C-n>'] = { 'select_next', 'fallback' },
                    ['<C-p>'] = { 'select_prev', 'fallback' },
                    ['<C-e>'] = { 'cancel', 'fallback' },
                    ['<CR>'] = { 'accept_and_enter', 'fallback' },
                },
            },
        },
    },
}
