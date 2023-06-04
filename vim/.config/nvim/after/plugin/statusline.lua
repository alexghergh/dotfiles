-- see :h status-line and :h statusline
-- see https://nihilistkitten.me/nvim-lua-statusline/

local function highlight(group, fg, bg)
    vim.cmd(string.format('highlight %s guifg=%s guibg=%s', group, fg, bg))
end

-- TODO
-- integrate vim.diagnostic.get() for diagnostics count
-- only call nvim_treesitter status line if treesitter exists for the current filetype
-- nvim_treesitter with more options
-- colors
-- see github.com/nihilistkitten/dotfiles/blob/main/nvim/lua/statusline.lua
function status_line()
    return table.concat {
        -- filename (truncate if too long)
        '%<%f',

        -- file attributes and diff stats
        '%k #%n %a ',
        vim.fn['sy#repo#get_stats_decorated'](),
        ' [', vim.o.fileencoding, ']',
        '%m%r%w%y%q ',

        -- scope as reported by treesitter
        vim.fn['nvim_treesitter#statusline'](),

        -- separator between left and right sides
        '%=',

        -- right side stuff (line, column, percentage, total LOC)
        '%-12.(%l,%c%V%)',
        '%p%% (out of %L)',
    }
end

vim.o.statusline = "%!luaeval('status_line()')"
vim.o.laststatus = 3
