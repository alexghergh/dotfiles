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

    -- nvim-wezterm navigation
    {
        'mrjones2014/smart-splits.nvim',
        opts = {
            at_edge = 'stop',
            cursor_follows_swapped_bufs = true,
        },
    },

    -- code diffs (TODO move to something else, highlight toggles don't
    -- seem to work anymore)
    { 'mhinz/vim-signify' },

    -- surroundings
    { 'tpope/vim-surround', dependencies = { 'tpope/vim-repeat' } },

    -- pairs of mappings
    { 'tpope/vim-unimpaired', dependencies = { 'tpope/vim-repeat' } },

    -- better UI
    { 'stevearc/dressing.nvim', opts = {}, event = 'VeryLazy' },

    -- fonts, glyphs, symbols
    {
        '2kabhishek/nerdy.nvim',
        dependencies = {
            'stevearc/dressing.nvim',
            -- 'nvim-telescope/telescope.nvim',
        },
        cmd = 'Nerdy',
    },

    -- secure modelines
    { 'alexghergh/securemodelines' },

    -- undotrees
    { 'mbbill/undotree' },

    -- colorschemes
    { 'savq/melange-nvim', lazy = false, priority = 1000, },

    -- indentlines (TODO adjust)
    { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },

    -- telescope stuff
    -- { 'nvim-telescope/telescope.nvim', tag = '0.1.3' },

    -- -- search highlighting
    -- use({ 'nvimdev/hlsearch.nvim' })
    --
    -- -- status line
    -- use({ 'nvimdev/galaxyline.nvim' })
    -- use({ 'SmiteshP/nvim-navic' })
}

opts = {}

require('lazy').setup(plugins, opts)

-- vim: set tw=0 fo-=r ft=lua
