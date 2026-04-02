return {

    -- buffer integration for git (inline diffs, hunks, text object)
    -- see :h gitsigns.txt
    {
        'lewis6991/gitsigns.nvim',
        opts = {
            sign_priority = 60,
            update_debounce = 50,
            attach_to_untracked = true,
        },
        config = function(_, opts)
            local gs = require('gitsigns')
            gs.setup(opts)

            -- populate quickfix list with hunks (per file and per project)
            vim.keymap.set('n', '<Leader>hq', gs.setqflist, { desc = 'Populate quickfix list with file hunks' })
            vim.keymap.set('n', '<Leader>hQ', function()
                gs.setqflist('all')
            end, { desc = 'Populate quickfix list with project hunks' })

            -- show commit info (TODO move to lazygit)
            vim.keymap.set('n', '<Leader>hc', function()
                vim.ui.input({ prompt = 'Commit: ', default = 'HEAD' }, function(input)
                    if input == nil then
                        return
                    end
                    input = vim.trim(input)
                    gs.show_commit(input ~= '' and input or nil)
                end)
            end, { desc = "Show vim.ui.input()'ed commit info in split" })

            -- show file at given revision (TODO move to codediff)
            vim.keymap.set('n', '<Leader>hf', function()
                vim.ui.input({ prompt = 'Base: ', default = 'HEAD' }, function(input)
                    if input == nil then
                        return
                    end
                    input = vim.trim(input)
                    gs.show(input ~= '' and input or nil)
                end)
            end, { desc = "Show file at vim.ui.input()'ed revision" })

            -- open file diff in split (TODO move this to codediff)
            vim.keymap.set('n', '<Leader>hd', gs.diffthis, { desc = 'Open file diff' })

            -- show file git blame ('s' on a blame line to show full commit info)
            vim.keymap.set('n', '<Leader>hb', gs.blame, { desc = 'Git blame the file' })

            -- hunk text objects
            vim.keymap.set({ 'o', 'x' }, 'ih', gs.select_hunk, { desc = 'Diff inner text object' })

            -- show diff in floating window
            vim.keymap.set('n', '<Leader>hs', gs.preview_hunk, { desc = 'Show diff under cursor' })
            vim.keymap.set('n', '<Leader>hi', gs.preview_hunk_inline, { desc = 'Show inlined diff under cursor' })

            -- hunk navigation
            -- stylua: ignore start
            vim.keymap.set('n', ']h', function() gs.nav_hunk('next', { navigation_message = true }) end, { desc = 'Move to next diff' })
            vim.keymap.set('n', '[h', function() gs.nav_hunk('prev', { navigation_message = true }) end, { desc = 'Move to previous diff' })
            vim.keymap.set('n', ']H', function() gs.nav_hunk('last', { navigation_message = true }) end, { desc = 'Move to last diff' })
            vim.keymap.set('n', '[H', function() gs.nav_hunk('first', { navigation_message = true }) end, { desc = 'Move to first diff' })
            -- stylua: ignore end

            -- stage / reset hunk
            vim.keymap.set('n', '<Leader>ha', gs.stage_hunk, { desc = 'Stage hunk under cursor' })
            vim.keymap.set('n', '<Leader>hA', gs.stage_buffer, { desc = 'Stage whole buffer' })
            vim.keymap.set('n', '<Leader>hr', gs.reset_hunk, { desc = 'Reset hunk under cursor' })
            vim.keymap.set('v', '<Leader>ha', function()
                gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end, { desc = 'Stage hunk visual selection' })
            vim.keymap.set('v', '<Leader>hr', function()
                gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end, { desc = 'Reset hunk visual selection' })

            -- toggle line, number and word diff highlighting
            vim.keymap.set('n', '<Leader>ht', function()
                gs.toggle_linehl()
                gs.toggle_numhl()
                gs.toggle_word_diff()
            end, { desc = 'Toggle diff line highlight' })
        end,
    },
}
