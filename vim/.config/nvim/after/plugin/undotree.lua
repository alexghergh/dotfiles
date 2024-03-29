--
-- see :h undotree.txt
--
if vim.g.loaded_undotree == nil then
    return nil
end

-- window layout
vim.g.undotree_WindowLayout = 2

-- automatically focus the undo history when opening it
vim.g.undotree_SetFocusWhenToggle = 1

-- short timestamp indicators
vim.g.undotree_ShortIndicators = 1

-- show undo-tree (mnemonic Undo Show)
vim.keymap.set('n', '<Leader>us', '<Cmd>UndotreeToggle<CR>')

-- vim: set tw=0 fo-=r ft=lua
