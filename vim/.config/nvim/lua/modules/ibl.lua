return {

    -- indentlines
    {
        'lukas-reineke/indent-blankline.nvim',
        opts = {
            indent = { char = '│' },
            scope = { show_exact_scope = true },
        },
        config = function(_, opts)
            require('ibl').setup(opts)
            vim.cmd([[set nolist]]) -- disable listchars
        end,
    },
}

-- vim: set tw=0 fo-=r ft=lua
