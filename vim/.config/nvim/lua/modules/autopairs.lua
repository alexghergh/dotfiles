return {

    -- auto insert matching pairs
    -- see also lua/modules/nvim-cmp.lua for auto () pairs on function insert
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        opts = {
            disable_filetype = { 'TelescopePrompt', 'snacks_input' },
            map_c_h = true, -- auto-delete pair on backspace if possible
            map_c_w = true, -- auto-delete pair on <c-w> if possible
        },
    },
}
