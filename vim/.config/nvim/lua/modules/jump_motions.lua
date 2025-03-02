return {

    -- better jump-around movements

    {
        -- highlights on f, F, t, T movement
        'jinh0/eyeliner.nvim',
        opts = {
            highlight_on_key = true,
            dim = true,
        },
    },
    {
        -- super-powered window jumps
        'ggandor/leap.nvim',
        config = function(_, _)
            -- define equivalence classes for brackets and quotes, in addition
            -- to the default whitespace group (you can search for any of the
            -- characters inside a string, and the others will also get picked
            -- up)
            require('leap').opts.equivalence_classes =
                { ' \t\r\n', '([{', ')]}', '\'"`' }

            -- define a preview filter (skip the middle of alphanumeric words)
            require('leap').opts.preview_filter = function(ch0, ch1, ch2)
                return not (
                    ch1:match('%s')
                    or ch0:match('%w')
                        and ch1:match('%w')
                        and ch2:match('%w')
                )
            end

            vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap)')
            vim.keymap.set({ 'n', 'x', 'o' }, 'gs', '<Plug>(leap-from-window)')

            -- remote action
            vim.keymap.set({ 'n', 'x', 'o' }, 'gS', function()
                require('leap.remote').action()
            end)

            -- treesitter node selection
            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>gs', function()
                require('leap.treesitter').select()
            end)
        end,
    },
}
