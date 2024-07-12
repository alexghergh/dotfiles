-- Author: alexghergh

--
-- Neovim config files (Lua edition)
--
-- see :h lua-guide
-- see :h lua
--

-- set Space as leader key early
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- source core built-in stuff (settings, autocommands, commands, keymaps,
-- diagnostics, lsp client)
require('core')

-- install and configure necessary plugins
require('plugins')

-- file-type specific stuff is processed later
-- see after/ftplugin/

-- vim: set tw=0 fo-=r ft=lua
