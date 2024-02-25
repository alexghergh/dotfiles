--
-- neovim lsp server configs
--
-- see :h vim.lsp
-- see :h lspconfig
--
local M = {}

if not pcall(require, 'lspconfig') then
    return nil
end

-- border for :LspInfo
require('lspconfig.ui.windows').default_options.border = 'rounded'

-- setup the lsp servers
function M.setup_servers(servers, capabilities, handlers)
    for _, lsp in ipairs(servers) do
        require('lspconfig')[lsp].setup({
            capabilities = capabilities,
            handlers = handlers,
        })
    end
end

return M

-- vim: set tw=0 fo-=r ft=lua
