--
-- see :h smart-splits.txt
--
local M = {}

if not pcall(require, 'smart-splits') then
    return nil
end

-- move cursor
vim.keymap.set('n', '<A-h>', require('smart-splits').move_cursor_left)
vim.keymap.set('n', '<A-l>', require('smart-splits').move_cursor_right)
vim.keymap.set('n', '<A-j>', require('smart-splits').move_cursor_down)
vim.keymap.set('n', '<A-k>', require('smart-splits').move_cursor_up)

-- resize split (these intentionally override the keymaps set in
-- lua/core/keymaps.lua, so we have a uniform keybind set even if this plugin is
-- not available)
vim.keymap.set('n', '<Leader>wh', require('smart-splits').resize_left)
vim.keymap.set('n', '<Leader>wl', require('smart-splits').resize_right)
vim.keymap.set('n', '<Leader>wj', require('smart-splits').resize_down)
vim.keymap.set('n', '<Leader>wk', require('smart-splits').resize_up)

-- swap neovim splits
vim.keymap.set('n', '<leader><leader>h', require('smart-splits').swap_buf_left)
vim.keymap.set('n', '<leader><leader>j', require('smart-splits').swap_buf_down)
vim.keymap.set('n', '<leader><leader>k', require('smart-splits').swap_buf_up)
vim.keymap.set('n', '<leader><leader>l', require('smart-splits').swap_buf_right)

return M

-- vim: set tw=0 fo-=r ft=lua
