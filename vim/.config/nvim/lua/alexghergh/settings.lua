-- Configuration ---------------------------------------------------------------

-- Global

-- python3 program, allows neovim to work in virtual environments
vim.g.python3_host_prog = "/home/alex/.pyenv/versions/3.9.5/bin/python"

-- <Space> as leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- wrap line prefix
vim.o.showbreak = "↪ "

-- amount of lines to keep above and below the cursor at all times
vim.o.scrolloff = 7

-- smart search
vim.o.ignorecase = true
vim.o.smartcase = true

-- highlight matched strings as typing occurs
vim.o.incsearch = true

-- allow neovim to copy and paste directly from the system clipboard
vim.opt.clipboard:append { "unnamedplus" }

-- don't unload buffers when switching, just hide them
vim.o.hidden = true

-- show diffs in vertical splits by default
vim.opt.diffopt:append { "vertical" }

-- update every 1 second after not typing anything
vim.o.updatetime = 1000

-- preview menu options for autocompletion
vim.opt.completeopt = { "menuone", "noselect" }

-- show the total number of substitutions
vim.o.report = 0

-- enable true 24-bit terminal colors
vim.o.termguicolors = true
vim.o.background = "dark"
vim.cmd([[colorscheme melange]])

-- ignore certain files when opening buffers from inside neovim
vim.opt.wildignore:append { "*.o", "*.obj", "**/.git/*", "*.swp", "*.pyc", "*.class", "**/node_modules/*", "*.bak" }
vim.o.wildmode = "longest:full,full"

-- incremental live completion
vim.o.inccommand = "nosplit"

-- prefer splitting windows below or to the right
vim.o.splitbelow = true
vim.o.splitright = true

-- add directories upwards as search path
vim.opt.path:append { "**" }

-- show tab characters, line-endings
vim.o.list = true
vim.opt.listchars = { ["tab"] = ">.", ["trail"] = "." , ["nbsp"] = "‸" }

-- enable spell-checking
-- vim.o.spell = true

-- options for netrw
vim.g.netrw_liststyle = 3       -- treestyle listing
vim.g.netrw_banner = 0          -- don't show the banner at the top (toggle with <S-i>)
vim.g.netrw_browse_split = 4    -- open files in the previous window
vim.g.netrw_winsize = 15        -- percent of window size


-- Window specific

-- show line numbers
vim.o.number = true
vim.o.relativenumber = true

-- display the sign column
vim.o.signcolumn = "yes"

-- visually break lines at max width
vim.o.linebreak = true

-- show the cursor line
vim.o.cursorline = true


-- Buffer specific

-- keep the same indentation level from previous line
vim.o.autoindent = true

-- tabs as spaces, tab size 4
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.tabstop=4

-- disable modelines in favor of secure modelines, see plugin below
vim.o.modeline = false

-- enable undo files, disable swap files
vim.o.undofile = true
vim.o.swapfile = false

-- format options, describe how autoformatting is done
vim.o.formatoptions = "tcrqnlj"

-- vim: set tw=0 fo-=r
