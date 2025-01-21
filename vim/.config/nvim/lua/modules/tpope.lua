return {

    -- repeat motions
    { 'tpope/vim-repeat', lazy = true },

    -- surroundings
    { 'tpope/vim-surround', dependencies = { 'tpope/vim-repeat' } },

    -- pairs of mappings
    { 'tpope/vim-unimpaired', dependencies = { 'tpope/vim-repeat' } },
}
