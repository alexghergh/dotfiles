--
-- autocommands
--
-- see :h lua-guide-autocommands
--

-- user group
local user_group = vim.api.nvim_create_augroup('_user_group', { clear = true })

-- highlight text on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.hl.on_yank({ higroup = 'Cursor', timeout = 200 })
    end,
    group = user_group,
})

-- open files to last known position (:h last-position-jump)
vim.api.nvim_create_autocmd('BufReadPost', {
    callback = function(ev)
        -- filetypes to ignore
        local regex = vim.regex('commit\\|rebase\\|help\\|quickfix\\|nofile')
        local filetype = vim.bo[ev.buf].filetype

        -- check filetype
        if regex:match_str(filetype) ~= nil then
            return
        end

        -- position of the "last-position" mark in the file (:h '")
        local mark_pos = vim.api.nvim_buf_get_mark(ev.buf, '"')[1]

        -- check valid position (file could've been modified outside vim)
        if mark_pos > 1 and mark_pos <= vim.api.nvim_buf_line_count(ev.buf) then
            vim.cmd([[ exe 'normal! g`"' ]])
        end
    end,
    group = user_group,
})

-- clean extra spaces at the end of a line
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = {
        '*.zsh',
        '*.vim',
        '*.c',
        '*.cpp',
        '*.txt',
        '*.js',
        '*.py',
        '*.wiki',
        '*.sh',
        '*.coffee',
        '*.java',
        '*.lua',
    },
    callback = function()
        local l = vim.fn.winsaveview()
        vim.cmd([[ keeppatterns silent! %s/\s\+$//e ]])
        vim.fn.winrestview(l)
    end,
    group = user_group,
})

-- add 2 blank lines at the beginning of a commit file when opened
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'gitcommit',
    callback = function(ev)
        local first_line = vim.api.nvim_buf_get_lines(ev.buf, 0, 1, false)[1] or ''
        if vim.startswith(first_line, '#') then
            vim.api.nvim_buf_set_lines(ev.buf, 0, 0, false, { '', '' })

            if vim.api.nvim_get_current_buf() == ev.buf then
                vim.api.nvim_win_set_cursor(0, { 1, 0 })
            end
        end
    end,
    group = user_group,
})
