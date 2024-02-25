--
-- neovim treesitter setup
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
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
        },
    },

    indent = {
        enable = true,
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

-- TODO move to lua/keymaps once the stuff in Playground is in core (nvim 0.10)
-- see github.com/nvim-treesitter/playground
-- it seems that highlight groups under cursor becomes :Inspect, while
-- TSPlaygroundToggle becomes :InspectTree; there doesn't seem to be any
-- built-in default for tsnodeundercursor, so unless one is included in core,
-- check the playground source code and move that here

-- show tree-sitter syntax group under cursor; mnemonic "SYntax"
vim.keymap.set('n', '<Leader>sy', '<Cmd>TSHighlightCapturesUnderCursor<CR>')

-- show tree-sitter node under cursor; mnemonic "Tree-sitter Node"
vim.keymap.set('n', '<Leader>tn', '<Cmd>TSNodeUnderCursor<CR>')

-- set folding function
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

-- display the current scope in the statusline
-- see API in lua/statusline.lua
function CursorScope()
    local result = vim.fn['nvim_treesitter#statusline']()
    if result ~= vim.NIL then
        return result
    end
    return ''
end

return M
