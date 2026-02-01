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
            -- characters inside a group, and the others will also be considered
            -- equivalent, i.e. searching for either (, [, or { will match a {)
            require('leap').opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }

            -- define a preview filter (skip the middle of alphanumeric words)
            require('leap').opts.preview_filter = function(ch0, ch1, ch2)
                return not (ch1:match('%s') or ch0:match('%a') and ch1:match('%a') and ch2:match('%a'))
            end

            -- movement
            vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap)', { desc = 'Leap in file' })
            vim.keymap.set('n', 'gs', '<Plug>(leap-from-window)', { desc = 'Leap from window' })

            -- remote action
            vim.keymap.set({ 'n', 'x', 'o' }, 'gS', function()
                require('leap.remote').action({ input = '' })
            end, { desc = 'Leap + remote action and come back' })

            -- treesitter node selection
            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>gs', function()
                require('leap.treesitter').select()
            end, { desc = 'Tree sitter leap visual selection' })
        end,
    },
}
