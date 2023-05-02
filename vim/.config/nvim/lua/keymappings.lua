--
-- keymappings
--
-- see :h vim.keymap
-- see :h nvim_set_keymap
--
-- notes:
--   - remap is false by default in vim.keymap.set
--   - other plugin-specific mappings are found in after/plugin/
--

--
-- non-<Leader> mappings
--

-- let j and k move inside a line visually even if it gets wrapped
-- for both normal and visual modes; if there is a count prefixed to the
-- command, then revert back to normal (so line numbers work correctly)
vim.keymap.set({ 'n', 'x' }, 'j', "v:count ? 'j' : 'gj'", { expr = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count ? 'k' : 'gk'", { expr = true })

-- make <C-w> and <C-u> undo friendly (see :h i_CTRL-G_u)
vim.keymap.set('i', "<C-w>", "<C-g>u<C-w>")
vim.keymap.set('i', "<C-u>", "<C-g>u<C-u>")

-- for when you REALLY want to save that buffer
vim.keymap.set('c', "w!!", "w !sudo tee % > /dev/null")

-- expands into the current file's working directory when typing
-- '%%' in command line
vim.keymap.set('c', "%%",
    "getcmdtype() == ':' ? expand('%:h') . '/' : '%%'" , { expr = true })


--
-- <Leader> mappings
--

-- since we remapped <Leader> to Space, just unmap Space
vim.keymap.set('n', ' ', '')

-- source vimrc
vim.keymap.set('n', "<Leader>sv", "<Cmd>source $MYVIMRC<CR>")

-- switch to last file
vim.keymap.set('n', "<Leader>o", "<C-^>")

-- open netrw in a vertical split
vim.keymap.set('n', "<Leader>ee", "<Cmd>Vexplore<CR>")

-- resize windows
vim.keymap.set('n', "<Leader>wk", "<Cmd>resize -10<CR>")
vim.keymap.set('n', "<Leader>wj", "<Cmd>resize +10<CR>")
vim.keymap.set('n', "<Leader>wh", "<Cmd>vertical resize -10<CR>")
vim.keymap.set('n', "<Leader>wl", "<Cmd>vertical resize +10<CR>")

-- toggle paste mode, useful when copy pasting from an outside source
vim.keymap.set('n', "<Leader>pt", "<Cmd>set invpaste<CR>")

-- navigate tags
vim.keymap.set('n', "<Leader>st", '<C-]>')

-- vim: set tw=0 fo-=r
