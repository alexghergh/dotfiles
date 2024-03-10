local M = {}

if not pcall(require, 'nvim-navic') then
    return nil
end

require('nvim-navic').setup({
    lsp = {
        auto_attach = true,
    }
})

-- M.is_available = require('nvim-navic').is_available
-- M.get_location = require('nvim-navic').get_location

-- set up winbar
vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

return M

-- vim: set tw=0 fo-=r ft=lua
