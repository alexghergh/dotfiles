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

-- core built-in stuff (settings, autocommands, commands, keymaps, diagnostics)
require('core')

-- install and configure necessary plugins
require('plugins')

-- file-type specific stuff is processed later
-- see after/ftplugin/
