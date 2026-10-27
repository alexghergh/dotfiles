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
                    -- disable latex formulas in chat buffers; interacts negatively with command-line $VAR in the output
                    codecompanion = { latex = { enabled = false } },
                },
            },
        },
    },
}
