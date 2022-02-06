require("nvim-treesitter.configs").setup {

    ensure_installed = {
        "c",
        "cpp",
        "java",
        "latex",
        "lua",
        "python",
        "query",
        "vim",
        "cmake",
        "make",
        "markdown",
        "bibtex"
    },

    -- nvim-treesitter highlighting
    highlight = {
        enable = true
    },

    -- nvim-treesitter indentation
    indent = {
        enable = true
    },

    -- nvim-treesitter playground
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
    }
}
