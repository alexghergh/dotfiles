--
-- see :h indent_blankline.txt
--
local M = {}

if not pcall(require, 'indent_blankline') then
    return nil
end

require('indent_blankline').setup({
    use_treesitter = true,
    disable_with_nolist = true,
    show_current_context = true,
    viewport_buffer = 50,
})

return M
