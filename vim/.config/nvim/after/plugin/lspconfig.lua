-- error checking
if not pcall(require, "lspconfig") then
    return
end

-- use an on_attach function to only set things up
-- after the language server attaches to a buffer
local custom_attach = function(client, bufnr)

    -- enable completion triggered by <C-x><C-o> in omnifunc
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- options for the nvim lsp keymaps
    local opts = { noremap = true, silent = true }

    -- go to *
    vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>gr", "<Cmd>lua vim.lsp.buf.references()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>gt", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", opts)

    -- show signature help/hover
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', "<C-k>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", opts)

    -- actions on the buffer
    vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>ca", "<Cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>=", "<Cmd>lua vim.lsp.buf.formatting()<CR>", opts)

    -- diagnostics
    vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>sd", "<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', "[d", "<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', "]d", "<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)

    -- compe setup
    require"compe".setup {
        enabled = true,
        autocomplete = true,
        documentation = true,
        source = {
            path = true,
            buffer = true,
            nvim_lsp = true,
            nvim_lua = true,
            luasnip = true,
        }
    }

    -- mappings for compe completion
    vim.api.nvim_buf_set_keymap(bufnr, 'i', "<CR>", "compe#confirm('<CR>')", { expr = true })
    vim.api.nvim_buf_set_keymap(bufnr, 'i', "<C-Space>", "compe#complete()", { expr = true })
    vim.api.nvim_buf_set_keymap(bufnr, 'i', "<C-e>", "compe#close('<C-e>')", { expr = true })

    -- draw a border around the hover and signature help boxes
    local border = {
        { "╔", "FloatBorder" },
        { "═", "FloatBorder" },
        { "╗", "FloatBorder" },
        { "║", "FloatBorder" },
        { "╝", "FloatBorder" },
        { "═", "FloatBorder" },
        { "╚", "FloatBorder" },
        { "║", "FloatBorder" },
    }

    vim.lsp.handlers["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, { border = border })
    vim.lsp.handlers["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.hover, { border = border })
end

-- enable function arguments completion through snippets
-- only for lsp servers that support it
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
        "documentation",
        "detail",
        "additionalTextEdits",
    }
}

-- use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = {
    "ccls",     -- c, cpp; installed through pacman ccls
    -- see github.com/MaskRay/ccls/wiki
    --"pyright",  -- python; installed through pacman pyright
    -- see github.com/microsoft/pyright
}

for _, lsp in ipairs(servers) do
    require'lspconfig'[lsp].setup {
        on_attach = custom_attach,
        capabilities = capabilities,
        flags = {
            debounce_text_changes = 150,
        },
    }
end
