-- Keymappings -----------------------------------------------------------------

-- astronauta things
if not pcall(require, "astronauta.keymap") then
    return
end

local map = vim.keymap.map
local nmap = vim.keymap.nmap
local noremap = vim.keymap.noremap
local nnoremap = vim.keymap.nnoremap
local imap = vim.keymap.imap
local inoremap = vim.keymap.inoremap
local lmap = vim.keymap.lmap
local lnoremap = vim.keymap.lnoremap
local omap = vim.keymap.omap
local onoremap = vim.keymap.onoremap
local tmap = vim.keymap.tmap
local tnoremap = vim.keymap.tnoremap
local cmap = vim.keymap.cmap
local cnoremap = vim.keymap.cnoremap
local xmap = vim.keymap.xmap
local xnoremap = vim.keymap.xnoremap
local smap = vim.keymap.smap
local snoremap = vim.keymap.snoremap
local vmap = vim.keymap.vmap
local vnoremap = vim.keymap.vnoremap


-- map jk and kj to esc
inoremap { "jk", "<Esc>" }
inoremap { "kj", "<Esc>" }

-- let j and k move inside a line visually even if it gets wrapped
nnoremap { 'j', "gj" }
nnoremap { 'k', "gk" }
xnoremap { 'j', "gj" } -- TODO: this interferes with luasnip,
xnoremap { 'k', "gk" } -- should find a workaround

-- some binds to make neovim a more 'pleasant' experience
noremap { "<Left>", "<Nop>" }
noremap { "<Down>", "<Nop>" }
noremap { "<Up>", "<Nop>" }
noremap { "<Right>", "<Nop>" }

inoremap { "<BS>", "<Nop>" }

-- make <C-w> and <C-u> undo friendly (see :h i_CTRL-G_U)
inoremap { "<C-w>", "<C-g>u<C-w>" }
inoremap { "<C-u>", "<C-g>u<C-u>" }

-- copy the rest of the line, instead of the whole line, similar to C or D
nnoremap { 'Y', "y$" }

-- source vimrc
nnoremap { "<Leader>sv", "<Cmd>source $MYVIMRC<CR>" }

-- switch to last file
nnoremap { "<Leader>ss", "<C-^>" }

-- open netrw in a vertical split
nnoremap { "<Leader>ee", "<Cmd>Vexplore<CR>" }

-- resize windows
-- TODO map to <leader>w + hjkl maybe
nnoremap { "<Leader>w-", "<Cmd>resize -10<CR>" }
nnoremap { "<Leader>w+", "<Cmd>resize +10<CR>" }
nnoremap { "<Leader>w<", "<Cmd>vertical resize -10<CR>" }
nnoremap { "<Leader>w>", "<Cmd>vertical resize +10<CR>" }

-- toggle paste mode, useful when copy pasting from an outside source
nnoremap { "<Leader>pt", "<Cmd>set invpaste<CR>" }

-- for when you REALLY want to save that buffer
cnoremap { "w!!", "w !sudo tee % > /dev/null" }

-- expands into the current file's working directory when typing '%%' in command line
cnoremap { "%%", "getcmdtype() == ':' ? expand('%:h') . '/' : '%%'" , expr = true }

-- show color
nnoremap { "<Leader>sc", "<Cmd>call functions#DisplayColorUnderCursorAsBackground()<CR>" }


-- vim: set tw=0 fo-=r
