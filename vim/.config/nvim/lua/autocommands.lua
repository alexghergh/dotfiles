--
-- autocommands
--
-- see https://neovim.io/doc/user/lua-guide.html#lua-guide-autocommands
--

-- user group
local user_group = vim.api.nvim_create_augroup('_user_group', { clear = true })

-- highlight text on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function() vim.highlight.on_yank({ timeout = 500 }) end,
    group = user_group
})

-- resize vim windows to equal lenghts when tmux zooms/unzooms
vim.api.nvim_create_autocmd('VimResized', {
    command = 'wincmd =',
    group = user_group
})

-- open files to last known position (:h last-position-jump)
vim.api.nvim_create_autocmd('BufReadPost', {
    callback = function()
        -- we have to create a second autocmd, which registers on filetype detection
        vim.api.nvim_create_autocmd('FileType', {
            callback = function()
                -- create a regex with the filetype patterns to match against
                local regex = vim.regex('commit\\|rebase\\|help\\|quickfix\\|nofile')

                -- position of the "last-position" mark in the file (:h '")
                local mark_pos = vim.fn.line([['"]])

                -- check filetype
                if regex:match_str(vim.bo.filetype) == nil then
                    -- check valid position (file could've been modified outside vim)
                    if mark_pos > 1 and mark_pos <= vim.fn.line("$") then
                        vim.cmd([[ exe 'normal! g`"' ]])
                    end
                end
            end,
            group = user_group
        })
    end,
    group = user_group
})

-- clean extra spaces at the end of a line
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.zsh', '*.vim', '*.c', '*.cpp', '*.txt', '*.js', '*.py', '*.wiki',
        '*.sh', '*.coffee', '*.java', '*.lua', },
    callback = function()
        local l = vim.fn.winsaveview()
        vim.cmd([[ keeppatterns silent! %s/\s\+$//e ]])
        vim.fn.winrestview(l)
    end,
    group = user_group
})

-- add 2 blank lines at the beginning of a commit file when opening
vim.api.nvim_create_autocmd('BufReadPost', {
    callback = function()
        -- we have to create a second autocmd, which registers on filetype detection
        vim.api.nvim_create_autocmd('FileType', {
            callback = function()
                -- check filetype
                if vim.bo.filetype:match('commit') ~= nil then
                    vim.cmd([[ exe 'normal OO' ]])
                end
            end,
            group = user_group
        })
    end,
    group = user_group
})

-- remove search highlighting on cursor move
vim.api.nvim_create_autocmd('CursorMoved', {
    command = 'call search#HlSearch()',
    group = user_group
})

vim.api.nvim_create_autocmd('InsertEnter', {
    command = 'call search#StopHL()',
    group = user_group
})

-- vim: set tw=0 fo-=r ft=lua
