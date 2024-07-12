--
-- configuration for the built-in neovim lsp client
--
-- see :h vim.lsp
--

-- use a custom LspAttach autocommand to map LSP keys only after
-- the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        -- options for the nvim lsp keymaps
        local opts = { buffer = args.buf }
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        -- buffer mappings for LSP servers

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
        vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format({ async = true })
        end, opts)

        -- code actions
        vim.keymap.set(
            { 'n', 'v' },
            '<Leader>ca',
            vim.lsp.buf.code_action,
            opts
        )

        -- symbol highlighting on hover
        if client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_augroup('lsp_doc_highlight', { clear = false })
            vim.api.nvim_clear_autocmds({
                buffer = args.buf,
                group = 'lsp_doc_highlight',
            })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = args.buf,
                group = 'lsp_doc_highlight',
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = args.buf,
                group = 'lsp_doc_highlight',
                callback = vim.lsp.buf.clear_references,
            })
        end
    end,
    group = vim.api.nvim_create_augroup('_user_group', { clear = false }),
})

-- vim: set tw=0 fo-=r ft=lua
