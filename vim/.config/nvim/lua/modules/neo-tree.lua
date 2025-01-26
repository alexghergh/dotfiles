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
        },
    },
    config = function(_, opts)
        require('neo-tree').setup(opts)

        -- default keymap
        vim.keymap.set(
            'n',
            '<Leader>nt',
            '<Cmd>Neotree source=last position=right toggle=true reveal=true<CR>'
        )
    end,
}
