-- Author: alexghergh

--
-- Neovim config files (Lua edition)
--
-- see https://neovim.io/doc/user/lua-guide.html
-- see https://neovim.io/doc/user/lua.html
--

-- set Space as leader key early
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- source settings
require('settings')

-- source autocommands
require('autocommands')

-- source user commands
require('commands')

-- source keymaps
require('keymaps')

-- source plugin installs
require('plugins')

-- colorscheme setup
require('colorscheme')
pcall(vim.cmd.colorscheme, 'melange')

-- diagnostics setup
require('diagnostics')

-- statusline setup
require('statusline')

-- lsp setup
require('lsp')

-- setup other plugins
require('init_plugins')

-- file-type specific stuff is processed later
-- see after/ftplugin/

-- vim: set tw=0 fo-=r ft=lua
