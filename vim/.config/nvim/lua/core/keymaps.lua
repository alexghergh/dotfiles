--
-- keymappings
--
-- see :h vim.keymap
-- see :h nvim_set_keymap
--
-- notes:
--   - remap is false by default in vim.keymap.set
--   - other plugin-specific mappings are found in lua/modules/*.lua
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

-- since we remapped <Leader> to Space, just unmap Space, to avoid the cursor
-- moving right "feature"
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>')

-- system yank/put
vim.keymap.set({ 'n', 'v' }, '<Leader>y', '"+y')
vim.keymap.set({ 'n', 'v' }, '<Leader>Y', '"+Y')
vim.keymap.set({ 'n', 'v' }, '<Leader>p', '"+p')
vim.keymap.set({ 'n', 'v' }, '<Leader>P', '"+P')

-- make delete just... delete (:h "_)
vim.keymap.set({ 'n', 'v' }, '<Leader>d', '"_d')
vim.keymap.set({ 'n', 'v' }, '<Leader>D', '"_D')

--
-- command-line keymaps
--

-- for when you REALLY want to save that buffer
vim.keymap.set('c', 'w!!', 'w !sudo tee % > /dev/null')

-- expand into the current file's working directory
vim.keymap.set(
    'c',
    '%%',
    "getcmdtype() == ':' ? expand('%:h') . '/' : '%%'",
    { expr = true }
)

--
-- navigation/code-flow keymaps
--

-- switch to last file
vim.keymap.set('n', '<Leader>o', '<C-^>')

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
-- see lua/core/diagnostics.lua for other diagnostics settings
-- see :h vim.diagnostic
--

-- show diagnostics in a floating window (mnemonic Diagnostics Show/Next/Prev)
vim.keymap.set('n', '<Leader>ds', vim.diagnostic.open_float)
vim.keymap.set('n', '<Leader>dn', vim.diagnostic.goto_next)
vim.keymap.set('n', '<Leader>dp', vim.diagnostic.goto_prev)

-- vim: set tw=0 fo-=r ft=lua
