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
-- diagnostics, lsp_client)
require('core')

-- setup custom colors
require('colorscheme')

-- install necessary plugins
require('plugins')

-- set up colorscheme (needs to run after plugin installs, so we have the
-- colorscheme already downloaded on fresh install)
pcall(vim.cmd.colorscheme, 'melange')

-- setup installed plugins
require('modules')

-- lsp servers setup
require('lsp_servers')

-- file-type specific stuff is processed later
-- see after/ftplugin/

-- vim: set tw=0 fo-=r ft=lua
