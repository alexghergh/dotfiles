if not pcall(require, 'lspconfig') then
    return
end

-- use a custom LspAttach autocommand to map LSP keys only after
-- the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)

        -- enable completion triggered by <C-x><C-o> in omnifunc
        vim.bo[event.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- options for the nvim lsp keymaps
        local opts = { buffer = event.buf }

        -- buffer mappings for LSP servers
        -- see :h vim.lsp

        -- most of the below override the builtins, which is exactly what we
        -- want, i.e. have the same mappings whether there is an LSP-server
        -- present or not

        -- goto *
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', '<Leader>gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<Leader>gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, opts) -- <L>gt

        -- signature help / hover
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

        -- symbol rename
        vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)

        -- formatting
        vim.keymap.set('n', '<Leader>f', vim.lsp.buf.format, opts) -- <L>=
        -- vim.keymap.set('n', '<space>f', function()
        --     vim.lsp.buf.format { async = true }
        -- end, opts)

        -- code actions
        vim.keymap.set({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action, opts)

        -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        -- vim.keymap.set('n', '<space>wl', function()
        --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        -- end, opts)

    end,
    group = vim.api.nvim_create_augroup('_user_group', { clear = false })
})

--     -- compe setup
--     require"compe".setup {
--         enabled = true,
--         autocomplete = true,
--         documentation = true,
--         source = {
--             path = true,
--             buffer = true,
--             nvim_lsp = true,
--             nvim_lua = true,
--             luasnip = true,
--         }
--     }

--     -- mappings for compe completion
--     vim.api.nvim_buf_set_keymap(bufnr, 'i', "<CR>", "compe#confirm('<CR>')", { expr = true })
--     vim.api.nvim_buf_set_keymap(bufnr, 'i', "<C-Space>", "compe#complete()", { expr = true })
--     vim.api.nvim_buf_set_keymap(bufnr, 'i', "<C-e>", "compe#close('<C-e>')", { expr = true })

--     -- draw a border around the hover and signature help boxes
--     local border = {
--         { "╔", "FloatBorder" },
--         { "═", "FloatBorder" },
--         { "╗", "FloatBorder" },
--         { "║", "FloatBorder" },
--         { "╝", "FloatBorder" },
--         { "═", "FloatBorder" },
--         { "╚", "FloatBorder" },
--         { "║", "FloatBorder" },
--     }

--     vim.lsp.handlers["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, { border = border })
--     vim.lsp.handlers["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.hover, { border = border })
-- end

-- -- enable function arguments completion through snippets
-- -- only for lsp servers that support it
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.textDocument.completion.completionItem.snippetSupport = true
-- capabilities.textDocument.completion.completionItem.resolveSupport = {
--     properties = {
--         "documentation",
--         "detail",
--         "additionalTextEdits",
--     }
-- }

-- -- use a loop to conveniently call 'setup' on multiple servers and
-- -- map buffer local keybindings when the language server attaches
-- local servers = {
--     "ccls",     -- c, cpp; installed through pacman ccls
--     -- see github.com/MaskRay/ccls/wiki
--     --"pyright",  -- python; installed through pacman pyright
--     -- see github.com/microsoft/pyright
-- }

-- -- TODO error checking just in case servers not installed, and print a message
-- for _, lsp in ipairs(servers) do
--     require'lspconfig'[lsp].setup {
--         on_attach = custom_attach,
--         capabilities = capabilities,
--         flags = {
--             debounce_text_changes = 150,
--         },
--     }
-- end
