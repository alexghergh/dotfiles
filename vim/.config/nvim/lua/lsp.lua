--
-- Language Server Protocol (LSP) setup
--
-- this includes setting up the lsp configs, as well as the auto-completion
-- engine managed by nvim-cmp, and any other off-spec lsp servers
--
-- see :h vim.lsp
-- see lua/utils/*
--

-- ! require returns 'true' if module returns nil
-- stylua: ignore start
if require('utils.lsp') == true then return end
if require('utils.lspconfig') == true then return end
if require('utils.neodev') == true then return end
if require('utils.luasnip') == true then return end
if require('utils.cmp') == true then return end
-- stylua: ignore end

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

require('utils.lspconfig').setup_servers(servers, capabilities, handlers)
