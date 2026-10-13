return {

    -- better markdown rendering
    {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { 'markdown', 'codecompanion' },
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
        opts = {
            render_modes = true,
            -- the chat buffer keeps the cursor on the line being streamed to, so
            -- un-rendering the cursor line redraws it on every chunk
            anti_conceal = { enabled = false },
            overrides = {
                filetype = {
                    -- on codecompanion buffers, redraw on every change instead of waiting
                    -- for a debounce, as the text keeps streaming in chat
                    codecompanion = { debounce = 0 },
                },
            },
        },
    },
}
