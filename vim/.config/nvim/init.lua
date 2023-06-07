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

-- source keymappings
require('keymappings')

-- source plugins
require('plugins')

-- colorscheme setup (see also after/plugin/colorscheme.lua)
pcall(vim.cmd.colorscheme, 'melange')

-- statusline setup
require('statusline')

-- other stuff is processed later
-- see after/{ftplugin,plugin}/

-- vim: set tw=0 fo-=r ft=lua
