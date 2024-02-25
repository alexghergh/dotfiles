--
-- init plugin configurations
-- additional plugin configs are sourced in after/plugin/
--
-- see lua/modules/*
-- see after/plugin/*
--

-- load modules ('require()' returns 'true' if module returns nil, i.e. the
-- plugin isn't installed)
require('modules.cmp')
require('modules.galaxyline')
require('modules.hlsearch')
require('modules.indentline')
require('modules.neodev') -- set up before lspconfig
require('modules.lspconfig')
require('modules.luasnip')
require('modules.nvim-tmux-navigation')
require('modules.telescope')
require('modules.treesitter')

-- vim: set tw=0 fo-=r ft=lua
