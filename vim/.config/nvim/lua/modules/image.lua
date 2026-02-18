return {

    -- paste images from clipboard
    --
    -- note: drag-and-drop images doesn't seem to be supported properly in wezterm;
    -- you can still e.g. drag and drop an image from dolphin, but URL's don't seem
    -- to work properly (you can still copy and paste an image from the internet,
    -- but that will save it locally)
    {
        'hakonharnes/img-clip.nvim',
        opts = {},
        config = function(_, opts)
            require('img-clip').setup(opts)

            -- Image Paste
            vim.keymap.set('n', '<Leader>ip', require('img-clip').paste_image, { desc = 'Paste image from clipboard' })

            -- process image before pasting (mnemonic Image Open)
            vim.keymap.set('n', '<Leader>io', function()
                vim.ui.input({ prompt = 'Image processing command', default = 'magick convert - -colorspace gray -' }, function(input)
                    require('img-clip').paste_image({ process_cmd = input })
                end)
            end, { desc = 'Process and paste image from clipboard' })
        end,
    },
}
