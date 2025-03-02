return {
    'nvim-treesitter/nvim-treesitter-textobjects',
    opts = {
        textobjects = {
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
                    ['af'] = '@function.outer',
                    ['if'] = '@function.inner',
                    ['at'] = '@parameter.outer', -- mnemonic Term
                    ['it'] = '@parameter.inner',
                    ['ac'] = '@class.outer',
                    ['ic'] = '@class.inner',
                    ['al'] = '@loop.outer',
                    ['il'] = '@loop.inner',
                },
            },
        },
    },
    config = function(_, opts)
        require('nvim-treesitter.configs').setup(opts)
    end,
}
