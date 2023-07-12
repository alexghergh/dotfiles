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
-- quality-of-life keymaps
--

-- let j and k move inside a line visually even if it gets wrapped
-- for both normal and visual modes; if there is a count prefixed to the
-- command, then revert back to normal (so line numbers work correctly)
vim.keymap.set({ 'n', 'x' }, 'j', "v:count ? 'j' : 'gj'", { expr = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count ? 'k' : 'gk'", { expr = true })

-- make <C-w> and <C-u> undo friendly (see :h i_CTRL-G_u)
vim.keymap.set('i', '<C-w>', '<C-g>u<C-w>')
vim.keymap.set('i', '<C-u>', '<C-g>u<C-u>')

-- since we remapped <Leader> to Space, just unmap Space, to avoid the annoying
-- cursor moving right feature
vim.keymap.set('n', ' ', '')

-- source vimrc
vim.keymap.set('n', '<Leader>sv', '<Cmd>source $MYVIMRC<CR>')


--
-- command-line keymaps
--

-- for when you REALLY want to save that buffer
vim.keymap.set('c', 'w!!', 'w !sudo tee % > /dev/null')

-- expands into the current file's working directory when typing
-- '%%' in command line
vim.keymap.set('c', '%%',
    "getcmdtype() == ':' ? expand('%:h') . '/' : '%%'" , { expr = true })


--
-- navigation/code-flow keymaps
--

-- switch to last file
vim.keymap.set('n', '<Leader>o', '<C-^>')

-- open netrw in a vertical split
vim.keymap.set('n', '<Leader>ee', '<Cmd>Vexplore<CR>')

-- navigate tags (mnemonic Switch Tag)
vim.keymap.set('n', '<Leader>st', '<C-]>')


--
-- window keymaps
--
vim.keymap.set('n', '<Leader>wk', '<Cmd>resize -10<CR>')
vim.keymap.set('n', '<Leader>wj', '<Cmd>resize +10<CR>')
vim.keymap.set('n', '<Leader>wh', '<Cmd>vertical resize -10<CR>')
vim.keymap.set('n', '<Leader>wl', '<Cmd>vertical resize +10<CR>')
vim.keymap.set('n', '<Leader>w=', '<Cmd>wincmd =<CR>')
vim.keymap.set('n', '<Leader>wz', '<Cmd>call functions#Zoom()<CR>')
vim.keymap.set('n', '<C-w><Leader>o', '<C-w><C-^>') -- splits and edits alternate file


--
-- diagnostics keymaps
--

-- diagnostics (see :h vim.diagnostic)
-- show diagnostics in a floating window (mnemonic Diagnostics Show/Next/Prev/Quickfix)
vim.keymap.set('n', '<Leader>ds', vim.diagnostic.open_float)
vim.keymap.set('n', '<Leader>dn', vim.diagnostic.goto_next)
vim.keymap.set('n', '<Leader>dp', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<Leader>dq', vim.diagnostic.setloclist) -- TODO keep this?

-- vim: set tw=0 fo-=r ft=lua
