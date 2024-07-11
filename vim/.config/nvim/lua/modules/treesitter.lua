--
-- see :h treesitter
-- see :h nvim-treesitter
--
local M = {}

if not pcall(require, 'nvim-treesitter.configs') then
    return nil
end

require('nvim-treesitter.configs').setup({
    ensure_installed = {
        'c',
        'cpp',
        'java',
        'latex',
        'lua',
        'python',
        'query',
        'vim',
        'cmake',
        'make',
        'markdown',
        'bibtex',
        'fish',
    },

    highlight = {
        enable = true,

        -- disable for HUGE files
        disable = function(_, buf)
            local max_filesize = 500 * 1024 -- 500 KB
            local ok, stats =
                pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,
    },

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<Leader>is',
            node_incremental = '<Leader>nu',
            node_decremental = '<Leader>nd',
            scope_incremental = '<Leader>su',
        },
    },

    indent = {
        enable = true,
    },
})

-- show tree-sitter syntax group under cursor; mnemonic "SYntax"
vim.keymap.set('n', '<Leader>sy', '<Cmd>Inspect<CR>')

-- show tree-sitter node under cursor; mnemonic "Tree-sitter Node"
vim.keymap.set('n', '<Leader>tn', '<Cmd>InspectTree<CR>')

-- set folding function
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

return M

-- vim: set tw=0 fo-=r ft=lua
