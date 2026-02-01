return {

    -- lightbulb for code actions
    -- see also lua/modules/colorschemes.lua
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
                text = '       👁', -- ⚡
                pos = 'eol',
            },
        },
    },
}
