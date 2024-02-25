--
-- configuration for the built-in neovim lsp client
--
-- see :h vim.lsp
--
local M = {}

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

        -- workspace folders
        -- vim.keymap.set('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
        -- vim.keymap.set('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
        -- vim.keymap.set('n', '<Leader>ww', function()
        --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        -- end, opts)
        -- vim.keymap.set('n', '<Leader>ws', vim.lsp.buf.workspace_symbol, opts)
    end,
    group = vim.api.nvim_create_augroup('_user_group', { clear = false }),
})

-- go to definition in a split window
local function goto_definition()
    local handler = function(_, result, _)
        if result == nil or vim.tbl_isempty(result) then
            vim.notify('No location found')
            return nil
        end
        vim.cmd('vsplit')
        if vim.tbl_islist(result) then
            vim.lsp.util.jump_to_location(result[1], 'utf-8')

            if #result > 1 then
                vim.fn.setqflist(
                    vim.lsp.util.locations_to_items(result, 'utf-8')
                )
                vim.api.nvim_command('copen')
                vim.api.nvim_command('wincmd p')
            end
        else
            vim.lsp.util.jump_to_location(result, 'utf-8')
        end
    end
    return handler
end

M.handlers = {
    -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization, 1st tip
    ['textDocument/hover'] = vim.lsp.with(
        vim.lsp.handlers.hover,
        { border = 'rounded' }
    ),
    ['textDocument/signatureHelp'] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        { border = 'rounded' }
    ),

    ['textDocument/definition'] = goto_definition(),
}

return M
