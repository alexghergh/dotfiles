--
-- Language Server Protocol (LSP) setup
--
-- this includes setting up the lsp configs, as well as the auto-completion
-- engine managed by nvim-cmp, and any other off-spec lsp servers
--
-- see :h vim.lsp
-- see lua/utils/*
--

-- ! require returns true if module returns nil
if require('utils.lsp') == true then return end
if require('utils.lspconfig') == true then return end
if require('utils.neodev') == true then return end
if require('utils.cmp') == true then return end

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

local capabilities = require('utils.cmp').default_capabilities()
local handlers = require('utils.lsp').handlers

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

require('utils.lspconfig').setup_servers(servers, capabilities, handlers)
