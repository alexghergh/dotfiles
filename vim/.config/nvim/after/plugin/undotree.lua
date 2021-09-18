-- disable vimade when using undo tree, and reenable it afterwards
-- for this to work, i added some commands directly to undotree
-- lines 474 and 484 in autoload/undotree.vim

-- show undo
vim.api.nvim_set_keymap('n', "<Leader>su", "<Cmd>UndotreeToggle<CR>", {})

-- window layout
vim.g.undotree_WindowLayout = 2

-- automatically focus the undo history when opening it
vim.g.undotree_SetFocusWhenToggle = 1
