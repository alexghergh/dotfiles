return {

    -- treesitter goodies
    -- see :h treesitter
    -- see :h nvim-treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        build = function()
            require('nvim-treesitter.install').update({ with_sync = true })()
        end,
        event = { 'VeryLazy' },
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
        init = function(_)
            -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
            -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
            -- no longer trigger the **nvim-treesitter** module to be loaded in time.
            -- Luckily, the only things that those plugins need are the custom queries, which we make available
            -- during startup. See https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/treesitter.lua
            -- require('lazy.core.loader').add_to_rtp(plugin)
            -- require('nvim-treesitter.query_predicates')
        end,
        cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
        keys = {
            {
                '<Leader>nu',
                desc = 'Increment node selection (mnemonic Node Up)',
            },
            {
                '<BS>',
                desc = 'Decrement node selection',
                mode = 'x',
            },
            {
                '<Leader>su',
                desc = 'Increment scope selection (mnemonic Scope Up)',
            },
            {
                '<Leader>sy',
                '<Cmd>Inspect<CR>',
                desc = 'Inspect syntax group under cursor (mnemonic SYntax)',
            },
            {
                '<Leader>tn',
                '<Cmd>InspectTree<CR>',
                desc = 'Show treesitter node under cursor (mnemonic Treesitter Node)',
            },
        },
        opts = {
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
                'html',
                'go',
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
                    init_selection = '<Leader>nu',
                    node_incremental = '<Leader>nu',
                    node_decremental = '<Bs>',
                    scope_incremental = '<Leader>su',
                },
            },

            indent = {
                enable = true,
            },
        },
        config = function(_, opts)
            require('nvim-treesitter.configs').setup(opts)

            -- show tree-sitter syntax group under cursor; mnemonic "SYntax"
            vim.keymap.set('n', '<Leader>sy', '<Cmd>Inspect<CR>')

            -- show tree-sitter node under cursor; mnemonic "Tree-sitter Node"
            vim.keymap.set('n', '<Leader>tn', '<Cmd>InspectTree<CR>')

            -- set folding function
            vim.o.foldmethod = 'expr'
            vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
        end,
    },
}

-- vim: set tw=0 fo-=r ft=lua
