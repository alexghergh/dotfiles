return {

    -- buffer integration for git (inline diffs, hunks, text object)
    -- see :h gitsigns.txt
    {
        'lewis6991/gitsigns.nvim',
        opts = {
            sign_priority = 5000,
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
            end, { desc = 'Show commit info in split' })

            -- show current file at a given revision
            vim.keymap.set('n', '<Leader>hf', function()
                vim.ui.input({ prompt = 'Revision: ', default = 'HEAD' }, function(input)
                    if input == nil then
                        return
                    end
                    input = vim.trim(input)
                    gs.show(input ~= '' and input or nil)
                end)
            end, { desc = 'Show current file at revision' })

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

    -- better code diffs
    {
        'esmuellert/codediff.nvim',
        opts = {
            diff = {
                original_position = 'right', -- position of HEAD / index
                conflict_ours_position = 'left', -- position of current changes
                compute_moves = true,
            },
            explorer = {
                initial_focus = 'modified',
            },
            keymaps = {
                view = {
                    -- these are the same mappings as the above gitsigns; keep them synced
                    next_hunk = ']h',
                    prev_hunk = '[h',
                    toggle_stage = '<Leader>hA',
                    stage_hunk = '<Leader>ha',
                    unstage_hunk = '<Leader>hu',
                    discard_hunk = '<Leader>hr',
                    hunk_textobject = 'ih',
                },
            },
        },
        config = function(_, opts)
            require('codediff').setup(opts)

            -- open project diff
            vim.keymap.set('n', '<Leader>hd', '<Cmd>CodeDiff<CR>', { desc = 'Open git diff explorer' })

            -- show project git history
            vim.keymap.set('n', '<Leader>hy', function()
                vim.ui.input({ prompt = 'Range: ' }, function(input)
                    if input == nil then
                        return
                    end
                    input = vim.trim(input)
                    vim.cmd({ cmd = 'CodeDiff', args = input ~= '' and { 'history', input } or { 'history' } })
                end)
            end, { desc = 'Open project git history' })

            -- show file git history
            vim.keymap.set('n', '<Leader>hF', function()
                vim.ui.input({ prompt = 'Range: ' }, function(input)
                    if input == nil then
                        return
                    end
                    input = vim.trim(input)
                    vim.cmd({ cmd = 'CodeDiff', args = input ~= '' and { 'history', input, '%' } or { 'history', '%' } })
                end)
            end, { desc = 'Open current file git history' })

            -- show visual selection history per file
            vim.keymap.set('x', '<Leader>hF', function()
                vim.ui.input({ prompt = 'Range: ' }, function(input)
                    if input == nil then
                        return
                    end
                    input = vim.trim(input)
                    vim.cmd({
                        cmd = 'CodeDiff',
                        args = input ~= '' and { 'history', input } or { 'history' },
                        range = { vim.fn.line("'<"), vim.fn.line("'>") },
                    })
                end)
            end, { desc = 'Open selected-line git history' })
        end,
    },
}
