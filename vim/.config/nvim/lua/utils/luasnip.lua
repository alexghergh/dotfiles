--
-- LuaSnip snippet support
--
-- see :h luasnip.txt
-- see utils/cmp.lua
--
local M = {}

if not pcall(require, 'luasnip') then
    return nil
end

-- snippet expand/jumps and change choice are mapped in utils/cmp.lua as
-- Tab/S-Tab/Ctrl-e

-- load vim-snippets
require('luasnip.loaders.from_snipmate').lazy_load()

M.ls = require('luasnip')

return M
