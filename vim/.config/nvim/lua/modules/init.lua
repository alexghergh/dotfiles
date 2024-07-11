--
-- init plugin configurations
-- additional plugin configs are sourced in after/plugin/
--
-- see lua/modules/*
-- see after/plugin/*
--

-- load modules ('require()' returns 'true' if module returns nil, i.e. the
-- plugin isn't installed); keep sorted
require('modules.cmp')
require('modules.galaxyline')
require('modules.luasnip')
require('modules.neodev')
require('modules.nvim-navic')
require('modules.nvim-tmux-navigation')
require('modules.smart-splits')
require('modules.telescope')
require('modules.treesitter')

require('modules.lspconfig') -- always keep last

-- vim: set tw=0 fo-=r ft=lua
