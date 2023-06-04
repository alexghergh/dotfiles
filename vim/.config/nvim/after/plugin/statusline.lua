-- see :h status-line and :h statusline

-- start setting up the statusline
vim.o.statusline = ''

-- filename (truncate if too long)
vim.opt.statusline:append '%<%f '

-- file attributes and diff stats
vim.opt.statusline:append '%k #%n %a %{sy#repo#get_stats_decorated()} '
vim.opt.statusline:append '[%{&fileencoding}]%m%r%w%y%q'

-- separator between left and right sides
vim.opt.statusline:append '%='

-- right side stuff (line, column, percentage, total LOC)
vim.opt.statusline:append '%-12.(%l,%c%V%)'
vim.opt.statusline:append '%p%% (out of %L)'
