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
require('utils.hlsearch')

-- TODO refactor this and all statusline into a proper plugin
local branch_info = ''

local Job = require('plenary.job')

-- see API in lua/statusline.lua
BranchInfo = function()
    Job:new({
        command = 'git',
        args = { 'rev-parse', '--abbrev-ref', 'HEAD' },
        cwd = '.',
        on_exit = function(data, _)
            local res = data:result()
            if not vim.tbl_isempty(res) then
                branch_info = res[1]
            else
                branch_info = ''
            end
        end,
    }):start()

    return branch_info
end
