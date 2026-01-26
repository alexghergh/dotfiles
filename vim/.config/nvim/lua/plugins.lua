--
-- plugins
--
-- see :h lazy.nvim.txt
-- see lua/modules/*.lua for plugin specs
--

-- if lazy.nvim is not installed, install it
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- import plugin specs from lua/modules/*.lua
require('lazy').setup('modules')
