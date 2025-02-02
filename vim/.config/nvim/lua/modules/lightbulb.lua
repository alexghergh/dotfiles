return {

    -- lightbulb for code actions
    {
        'kosayoda/nvim-lightbulb',
        opts = {
            autocmd = {
                enabled = true,
            },
            sign = {
                enabled = false,
            },
            virtual_text = {
                enabled = true,
                text = '    👁', -- ⚡
                hl = vim.api.nvim_set_hl(
                    0,
                    'LightBulbVirtualText',
                    { link = '@markup.heading.2.markdown' }
                ),
            },
        },
    },
}
