--
-- init built-in stuff
--

-- source settings
require('core.settings')

-- source autocommands
require('core.autocommands')

-- source user commands
require('core.commands')

-- source keymaps
require('core.keymaps')

-- built-in diagnostics setup
require('core.diagnostics')

-- built-in lsp client setup
require('core.lsp_client')

-- vim: set tw=0 fo-=r ft=lua
