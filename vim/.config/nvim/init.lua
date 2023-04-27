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
require('alexghergh.settings')

-- source keymappings
require('alexghergh.keymappings')

-- source autocommands
require('alexghergh.autocommands')

-- source globals
require('alexghergh.globals')

-- source plugins
require('alexghergh.plugins')

-- other stuff is processed later
-- see after/{ftplugin,plugin}/


-- vim: set tw=0 fo-=r
