if not pcall(require, 'nvim-treesitter.configs') then
    return
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
    },

    highlight = {
        enable = true,

        -- disable for HUGE files
        disable = function(lang, buf)
            local max_filesize = 500 * 1024 -- 500 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end
    },

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
        }
    },

    indent = {
        enable = true
    },

    playground = {
        enable = true,
        updatetime = 25,
        persist_queries = false,
        keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injected_languages = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<CR>',
            show_help = '?',
        },
    },

    query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { 'BufWrite', 'CursorHold' },
    },
})

-- set folding function
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
