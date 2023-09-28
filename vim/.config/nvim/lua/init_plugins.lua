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

-- TODO refactor this and all statusline into a proper plugin
local branch_info = ''

-- see API in lua/statusline.lua
BranchInfo = function()
    return branch_info
end

local Job = require('plenary.job')

Job:new({
    command = 'git',
    args = { 'rev-parse', '--abbrev-ref', 'HEAD' },
    cwd = '.',
    on_stdout = function(err, data)
        assert(not err, err)
        branch_info = data
    end,
}):start()
