--
-- init plugins configurations
-- additional plugin configs are sourced in after/plugin/
--
-- see lua/utils/*
-- see after/plugin/*
--

-- load modules (! require returns 'true' if module returns nil, i.e. the
-- plugin isn't installed)
require('utils.nvim-tmux-navigation')
require('utils.treesitter')
require('utils.indentline')

-- see API in lua/statusline.lua
BranchInfo = function()
    return ""
    -- TODO this seems to be very expensive, or something else seems to happen,
    -- as the mouse flickers continuously; commenting this solves it entirely
    -- return vim.fn.system('git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d "\\n"')
end
