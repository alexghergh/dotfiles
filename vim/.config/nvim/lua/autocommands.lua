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
                local regex = vim.regex("commit\\|rebase\\|help\\|quickfix\\|nofile")

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

-- vim.api.nvim_create_autocmd('CursorMoved', {
--     command = "set nohlsearch"
-- })


-- TODO
-- vim.cmd([[
-- autocmd CursorMoved * set nohlsearch
-- "nnoremap n n:set hlsearch<cr>
-- ]])
-- vim.cmd([[ nnoremap n n:set hlsearch<cr>]])

-- stop highlighting on cursor movement
-- local search_highlight_group = vim.api.nvim_create_augroup('_search_highlight', { clear = true })

-- vim.api.nvim_create_autocmd('CursorMoved', {
--     -- TODO make this a lua function
--     command = 'call search#HlSearch()',
--     group = search_highlight_group
-- })

-- vim.api.nvim_create_autocmd('InsertEnter', {
--     -- TODO make this a lua function
--     command = 'call search#StopHL()',
--     group = search_highlight_group
-- })
