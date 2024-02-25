local M = {}

if not pcall(require, 'hlsearch') then
    return nil
end

require('hlsearch').setup()

return M
