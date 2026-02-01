return {

    -- repeat motions
    { 'tpope/vim-repeat' },

    -- surroundings
    { 'tpope/vim-surround', dependencies = { 'tpope/vim-repeat' } },

    -- pairs of mappings
    -- see also util.lua, where 'yo' toggling is manually defined for which-key.nvim
    { 'tpope/vim-unimpaired', dependencies = { 'tpope/vim-repeat' } },
}
