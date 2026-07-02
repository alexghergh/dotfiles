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

    -- super-powered window jumps
    {
        'ggandor/leap.nvim',
        config = function(_, _)
            -- define equivalence classes for brackets and quotes, in addition
            -- to the default whitespace group (you can search for any of the
            -- characters inside a group, and the others will also be considered
            -- equivalent, i.e. searching for either (, [, or { will match a {)
            require('leap').opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }

            -- define a preview filter (skip the middle of alphanumeric words)
            require('leap').opts.preview = function(ch0, ch1, ch2)
                return not (ch1:match('%s') or ch0:match('%a') and ch1:match('%a') and ch2:match('%a'))
            end

            -- movement
            vim.keymap.set({ 'n', 'x', 'o' }, 'S', function()
                require('leap').leap({ opts = require('leap.user').with_traversal_keys('S', 's') })
            end, { desc = 'Leap in file' })
            vim.keymap.set('n', 'gs', '<Plug>(leap-anywhere)', { desc = 'Leap from window' })

            -- remote action
            vim.keymap.set({ 'n', 'x', 'o' }, 'gS', function()
                require('leap.remote').action({ input = '' })
            end, { desc = 'Leap + remote action and come back' })

            -- treesitter node selection; while the labels are shown, cycle up/down with S/s
            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>gs', function()
                require('leap.treesitter').select({ opts = require('leap.user').with_traversal_keys('S', 's') })
            end, { desc = 'Tree sitter leap visual selection' })

            -- search integration: <C-s> leaps to visible matches of the last `/` search pattern in normal mode;
            -- in commandline mode, `/pattern<C-s>` searches and immediately labels the matches;
            -- traversal via <C-s><C-s>... cycles through matches
            vim.keymap.set({ 'n', 'x', 'o', 'c' }, '<C-s>', function()
                local cmdline_mode = vim.fn.mode(true):match('^c')
                if cmdline_mode then
                    -- finish the / or ? search command first
                    vim.api.nvim_feedkeys(vim.keycode('<enter>'), 't', false)
                end
                if vim.fn.searchcount().total < 1 then
                    return
                end

                -- suppress hlsearch highlighting during the leap so the labels remain readable;
                -- next search or n/N brings the highlights back naturally
                vim.cmd('nohlsearch')

                -- vim.schedule() to let cmdline chores finish before invoking leap
                vim.schedule(function()
                    require('leap').leap({
                        pattern = vim.fn.getreg('/'),
                        -- windows = { current_win } makes leap search the whole visible window (from
                        -- w0 to w$) instead of only forward from cursor; matches `<Plug>(leap)` behavior
                        windows = { vim.api.nvim_get_current_win() },
                        inclusive = true,
                        opts = require('leap.user').with_traversal_keys('<C-s>', nil, {
                            -- no autojump to second match when cmdline mode without incsearch (confusing); keep n/N usable in any case
                            safe_labels = (cmdline_mode and not vim.o.incsearch) and ''
                                or require('leap').opts.safe_labels:gsub('[nN]', ''),
                        }),
                    })
                end)
            end, { desc = 'Leap to search matches' })
        end,
    },
}
