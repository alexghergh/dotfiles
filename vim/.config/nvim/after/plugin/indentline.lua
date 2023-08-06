if not pcall(require, 'indent_blankline') then
    return
end

require('indent_blankline').setup({
    use_treesitter = true,
    disable_with_nolist = true,
    show_current_context = true,
    viewport_buffer = 50,
})
