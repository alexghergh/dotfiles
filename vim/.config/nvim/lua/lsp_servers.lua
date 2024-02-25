--
-- lsp servers setup
--
-- this includes setting up the lsp configs, as well as the auto-completion
-- engine managed by nvim-cmp, and any other off-spec lsp servers
--
-- see :h vim.lsp
-- see lua/modules/*
--

-- can't set up lsp if any of the below aren't present
-- require returns 'true' if module returns nil
-- stylua: ignore start
if require('modules.lspconfig') == true then return end
if require('modules.neodev') == true then return end
if require('modules.luasnip') == true then return end
if require('modules.cmp') == true then return end
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

local capabilities = require('modules.cmp').default_capabilities()
local handlers = require('core.lsp_client').handlers

require('modules.lspconfig').setup_servers(servers, capabilities, handlers)
