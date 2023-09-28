--
-- see :h indent-blankline.txt
-- see lua/coroscheme.lua
--
local M = {}

if not pcall(require, 'ibl') then
    return nil
end

require('ibl').setup()

return M
