P = function(v)
    print(vim.inspect(v))
    return v
end

-- RELOAD = function(...)
--     return require("plenary.reload").reload_module(...)
-- end

-- R = function(name)
--     RELOAD(name)
--     return require(name)
-- end
--

create_virt_text = function()
    local bufnr = vim.fn.bufnr('%')
    local ns_id = vim.api.nvim_create_namespace('demo')

    local line_num = 0
    local col_num = 5

    local opts = {
        end_line = 10,
        id = 1,
        virt_text = {{"demo", "IncSearch"}},
        virt_text_pos = 'overlay',
        -- virt_text_win_col = 20,
    }

    local mark_id = vim.api.nvim_buf_set_extmark(bnr, ns_id, line_num, col_num, opts)
end
