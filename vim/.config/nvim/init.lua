-- Author: alexghergh

--
-- Neovim config files (Lua edition)
--
-- see https://neovim.io/doc/user/lua-guide.html
-- see https://neovim.io/doc/user/lua.html
--

-- set <Space> as leader key early
vim.g.mapleader = '<Space>'
vim.g.maplocalleader = '<Space>'

-- source settings
require('settings')

-- source keymappings
require('keymappings')

-- source autocommands
require('autocommands')

-- source globals
require('globals')

-- source plugins
require('plugins')

-- set colorscheme
vim.cmd.colorscheme("melange")

-- other stuff is processed later
-- see after/{ftplugin,plugin}/


-- vim: set tw=0 fo-=r
