return {

    -- file tree explorer
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons',
        'MunifTanjim/nui.nvim',
        -- "3rd/image.nvim", -- image support in previews
    },
    opts = {
        close_if_last_window = true,
        popup_border_style = '',
        clipboard = {
            sync = 'universal',
        },
        source_selector = {
            winbar = true,
            statusline = false,
        },
        window = {
            mappings = {
                ['P'] = {
                    'toggle_preview',
                    config = {
                        use_float = true,
                    },
                },
            },
            position = 'right',
            width = 70,
        },
        filesystem = {
            filtered_items = {
                hide_dotfiles = false,
            },
        },
    },
    config = function(_, opts)
        require('neo-tree').setup(opts)

        -- default keymap
        vim.keymap.set('n', '<Leader>nt', '<Cmd>Neotree source=last toggle=true reveal=true<CR>', { desc = 'Open Neotree' })
    end,
}
