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
        config = function(_, opts)
            local npairs = require('nvim-autopairs')

            npairs.setup(opts)

            -- exception for codecompanion filetype, which is basically an .md
            table.insert(npairs.get_rule('```').filetypes, 'codecompanion')
            table.insert(npairs.get_rule('```.*$').filetypes, 'codecompanion')

            -- pairs also autocomplete if selecting a function from the completion menu
            -- see lua/modules/nvim-cmp.lua
        end,
    },

    -- move to autopairs on multi-line as well, from insert mode
    {
        'alexghergh/pairs-jump.nvim',
        opts = {},
    },
}
