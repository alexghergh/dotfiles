--
-- see :h indent-blankline.txt
-- see lua/colorscheme.lua
--
local M = {}

if not pcall(require, 'ibl') then
    return nil
end

require('ibl').setup()

return M

-- vim: set tw=0 fo-=r ft=lua
