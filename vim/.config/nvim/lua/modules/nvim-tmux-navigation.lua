return {
    {
        'alexghergh/nvim-tmux-navigation',
        opts = {
            disable_when_zoomed = true,
            keybindings = {
                left = '<M-h>',
                down = '<M-j>',
                up = '<M-k>',
                right = '<M-l>',
                last_active = '<Leader>lp',
            },
        },
        lazy = true,
    },
}
