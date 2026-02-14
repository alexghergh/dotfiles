return {

    'hakonharnes/img-clip.nvim',
    opts = {},
    config = function(_, opts)
        require('img-clip').setup(opts)

        -- Image Paste
        vim.keymap.set('n', '<Leader>ip', require('img-clip').paste_image, { desc = 'Paste image from clipboard' })

        -- process image before pasting (mnemonic Image Open)
        vim.keymap.set(
            'n',
            '<Leader>io',
            ":lua require('img-clip').paste_image({process_cmd='magick convert - -colorspace gray -'})",
            { desc = 'Process and paste image from clipboard' }
        )
    end,
}
