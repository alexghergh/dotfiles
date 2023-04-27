-- Keymappings -----------------------------------------------------------------
--
--
-- see :help vim.keymap
-- remap is false by default
--


-- map jk and kj to esc
vim.keymap.set('i', "jk", "<Esc>")
vim.keymap.set('i', "kj", "<Esc>")

-- let j and k move inside a line visually even if it gets wrapped
vim.keymap.set('n', 'j', "gj")
vim.keymap.set('n', 'k', "gk")
vim.keymap.set('x', 'j', "gj") -- TODO: this interferes with luasnip,
vim.keymap.set('x', 'k', "gk") -- should find a workaround

-- nnoremap j :<C-U>execute "if v:count1==1 <bar> normal gj <bar> endif"<CR>



-- else echo v:count1 . 'j' endif"<CR>

-- some binds to make neovim a more 'pleasant' experience
vim.keymap.set('', "<Left>", "<Nop>")
vim.keymap.set('', "<Down>", "<Nop>")
vim.keymap.set('', "<Up>", "<Nop>")
vim.keymap.set('', "<Right>", "<Nop>")

vim.keymap.set('', "<BS>", "<Nop>")

-- make <C-w> and <C-u> undo friendly (see :h i_CTRL-G_U)
vim.keymap.set('i', "<C-w>", "<C-g>u<C-w>")
vim.keymap.set('i', "<C-u>", "<C-g>u<C-u>")

-- source vimrc
vim.keymap.set('n', "<Leader>sv", "<Cmd>source $MYVIMRC<CR>")

-- switch to last file
vim.keymap.set('n', "<Leader>ss", "<C-^>")

-- open netrw in a vertical split
vim.keymap.set('n', "<Leader>ee", "<Cmd>Vexplore<CR>")

-- resize windows
-- TODO map to <leader>w + hjkl maybe
vim.keymap.set('n', "<Leader>w-", "<Cmd>resize -10<CR>")
vim.keymap.set('n', "<Leader>w+", "<Cmd>resize +10<CR>")
vim.keymap.set('n', "<Leader>w<", "<Cmd>vertical resize -10<CR>")
vim.keymap.set('n', "<Leader>w>", "<Cmd>vertical resize +10<CR>")

-- toggle paste mode, useful when copy pasting from an outside source
vim.keymap.set('n', "<Leader>pt", "<Cmd>set invpaste<CR>")

-- for when you REALLY want to save that buffer
vim.keymap.set('c', "w!!", "w !sudo tee % > /dev/null")

-- expands into the current file's working directory when typing '%%' in command line
vim.keymap.set('c', "%%", "getcmdtype() == ':' ? expand('%:h') . '/' : '%%'" , { expr = true })

-- show color
vim.keymap.set('n', "<Leader>sc", "<Cmd>call functions#DisplayColorUnderCursorAsBackground()<CR>")

-- navigate tags
vim.keymap.set('n', "<Leader>st", '<C-]>')

-- vim: set tw=0 fo-=r
