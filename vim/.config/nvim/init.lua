-- Author: alexghergh

--
-- Neovim config files (Lua edition)
--
-- see https://neovim.io/doc/user/lua-guide.html
-- see https://neovim.io/doc/user/lua.html

-- set <Space> as leader key early
vim.g.mapleader = '<Space>'
vim.g.maplocalleader = '<Space>'

-- source plugins
require('alexghergh.plugins')

-- source global settings
require('alexghergh.settings')

-- source keymappings
require('alexghergh.keymappings')

-- source globals
require('alexghergh.globals')

-- TODO move this somewhere else
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
    -- TODO split the line below, or just move somewhere else
    command = [[
        if &ft !~# 'commit\|rebase' && line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"' | endif
    ]],
    group = user_group
})

-- clean extra spaces at the end of a line
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.zsh', '*.vim', '*.c', '*.cpp', '*.txt', '*.js', '*.py', '*.wiki',
        '*.sh', '*.coffee', '*.java', '*.lua', },
    -- TODO make this a lua function
    command = ':call functions#CleanExtraSpaces()',
    group = user_group
})


-- stop highlighting on cursor movement
local search_highlight_group = vim.api.nvim_create_augroup('_search_highlight', { clear = true })

vim.api.nvim_create_autocmd('CursorMoved', {
    -- TODO make this a lua function
    command = 'call search#HlSearch()',
    group = search_highlight_group
})

vim.api.nvim_create_autocmd('InsertEnter', {
    -- TODO make this a lua function
    command = 'call search#StopHL()',
    group = search_highlight_group
})
