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

-- in insert mode, move cursor left/right/down/up using Alt key
vim.keymap.set('i', '<A-h>', function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_win_set_cursor(0, { row, col ~= 0 and col - 1 or col })
end, { desc = 'Move left in insert mode' })
vim.keymap.set('i', '<A-l>', function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line_len = #vim.api.nvim_get_current_line()
    vim.api.nvim_win_set_cursor(0, { row, col ~= line_len and col + 1 or col })
end, { desc = 'Move right in insert mode' })
vim.keymap.set('i', '<A-j>', function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local buf_len = vim.api.nvim_buf_line_count(0)
    vim.api.nvim_win_set_cursor(0, { row ~= buf_len and row + 1 or row, col })
end, { desc = 'Move down in insert mode' })
vim.keymap.set('i', '<A-k>', function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_win_set_cursor(0, { row ~= 1 and row - 1 or row, col })
end, { desc = 'Move up in insert mode' })

-- make <C-w> and <C-u> undo friendly (see :h i_CTRL-G_u)
vim.keymap.set('i', '<C-w>', '<C-g>u<C-w>')
vim.keymap.set('i', '<C-u>', '<C-g>u<C-u>')

-- since we remapped <Leader> to Space, just unmap Space, to avoid the cursor
-- moving right "feature"
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>')

-- system yank/put
vim.keymap.set({ 'n', 'v' }, '<Leader>y', '"+y', { desc = 'System clipboard yank' })
vim.keymap.set({ 'n', 'v' }, '<Leader>Y', '"+Y', { desc = 'System clipboard yank' })
vim.keymap.set({ 'n', 'v' }, '<Leader>p', '"+p', { desc = 'System clipboard put' })
vim.keymap.set({ 'n', 'v' }, '<Leader>P', '"+P', { desc = 'System clipboard put' })

-- make delete just... delete (:h "_)
vim.keymap.set({ 'n', 'v' }, '<Leader>d', '"_d', { desc = 'Delete without register' })
vim.keymap.set({ 'n', 'v' }, '<Leader>D', '"_D', { desc = 'Delete without register' })

--
-- command-line keymaps
--

-- for when you REALLY want to save that buffer
vim.keymap.set('c', 'w!!', 'w !sudo tee % > /dev/null')

-- expand into the current file's working directory
vim.keymap.set('c', '%%', "getcmdtype() == ':' ? expand('%:h') . '/' : '%%'", { expr = true })

--
-- navigation/code-flow keymaps
--

-- switch to last file
vim.keymap.set('n', '<Leader>o', '<C-^>', { desc = 'Switch to last file' })

-- navigate tags (mnemonic Switch Tag)
vim.keymap.set('n', '<Leader>st', '<C-]>', { desc = 'Navigate to tag' })

--
-- window keymaps
--
vim.keymap.set('n', '<Leader>wk', '<Cmd>resize -10<CR>', { desc = 'Resize window height (-10)' })
vim.keymap.set('n', '<Leader>wj', '<Cmd>resize +10<CR>', { desc = 'Resize window height (+10)' })
vim.keymap.set('n', '<Leader>wh', '<Cmd>vertical resize -10<CR>', { desc = 'Resize window width (-10)' })
vim.keymap.set('n', '<Leader>wl', '<Cmd>vertical resize +10<CR>', { desc = 'Resize window width (+10)' })
vim.keymap.set('n', '<Leader>w=', '<Cmd>wincmd =<CR>', { desc = 'Make windows equal' })
vim.keymap.set('n', '<C-w><Leader>o', '<C-w><C-^>', { desc = 'Split and edit alternate file' })

--
-- diagnostics keymaps
-- see lua/core/diagnostics.lua for other diagnostics settings
-- see :h vim.diagnostic
--

-- show diagnostics in a floating window (mnemonic Diagnostics Show)
vim.keymap.set('n', '<Leader>ds', vim.diagnostic.open_float, { desc = 'Open diagnostic window' })
