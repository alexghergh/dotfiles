return {

    -- textobjects powered selection / navigation
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        opts = {
            textobjects = {

                -- select textobjects
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
                        -- ['as'] = '@scope.outer', -- overrides sentence textobj
                        -- ['is'] = '@scope.inner',
                    },
                    selection_modes = {
                        ['@function.outer'] = 'V',
                        ['@function.inner'] = 'V',
                        ['@class.outer'] = 'V',
                        ['@class.inner'] = 'V',
                    },
                },

                -- swap textobjects
                swap = {
                    enable = true,
                    swap_next = {
                        ['<Leader>np'] = '@parameter.inner',
                    },
                    swap_previous = {
                        ['<Leader>tp'] = '@parameter.inner',
                    },
                },

                -- move to textobjects (pairs of [, ])
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        [']m'] = '@function.outer',
                    },
                    goto_next_end = {
                        [']M'] = '@function.outer',
                    },
                    goto_previous_start = {
                        ['[m'] = '@function.outer',
                    },
                    goto_previous_end = {
                        ['[M'] = '@function.outer',
                    },
                },
            },
        },
        config = function(_, opts)
            require('nvim-treesitter.configs').setup(opts)
        end,
    }
}
