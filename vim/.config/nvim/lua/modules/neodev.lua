--
-- neovim development lsp setup
-- off spec lsp to assist in lua neovim configs
-- sets up runtime dependencies for neovim stuff
--
-- see :h neodev
--
local M = {}

if not pcall(require, 'neodev') then
    return
end

require('neodev').setup({})

return M

-- vim: set tw=0 fo-=r ft=lua
