--
-- plugins
--

-- if lazy.nvim is not installed, install it
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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

plugins = {
    -- plugin manager manages itself
    { 'folke/lazy.nvim' },



}

opts = {}

require('lazy').setup(plugins, opts)

-- vim: set tw=0 fo-=r ft=lua
