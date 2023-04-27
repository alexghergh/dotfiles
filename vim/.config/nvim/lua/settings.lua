-- neovim settings

--
-- global
--

-- python3 program, allows neovim to work in virtual environments
-- todo update this based on paths and environment variables, possibly set an
-- environment variable inside zsh
vim.g.python3_host_prog = "/home/alex/.pyenv/versions/3.9.5/bin/python"

-- wrap line prefix
vim.opt.showbreak = "↪ "

-- amount of lines to keep above and below the cursor at all times
vim.opt.scrolloff = 7

-- smart search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- highlight matched strings as typing occurs
vim.opt.incsearch = true

-- allow neovim to copy and paste directly from the system clipboard
vim.opt.clipboard:append { "unnamedplus" }

-- don't unload buffers when switching, just hide them
vim.opt.hidden = true

-- show diffs in vertical splits by default
vim.opt.diffopt:append { "vertical" }

-- update every 1 second after not typing anything
vim.opt.updatetime = 1000

-- preview menu options for autocompletion
vim.opt.completeopt = { "menuone", "noselect" }

-- show the total number of substitutions
vim.opt.report = 0

-- enable true 24-bit terminal colors
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- set colorscheme
-- TODO move this somewhere else
vim.cmd([[silent! colorscheme melange]])

-- ignore certain files when opening buffers from inside neovim
vim.opt.wildignore:append { "*.o", "*.obj", "**/.git/*", "*.swp", "*.pyc", "*.class", "**/node_modules/*", "*.bak" }
vim.opt.wildmode = "longest:full,full"

-- incremental live completion
vim.opt.inccommand = "nosplit"

-- prefer splitting windows below or to the right
vim.opt.splitbelow = true
vim.opt.splitright = true

-- add directories upwards as search path
vim.opt.path:append { "**" }

-- show tab characters, line-endings
vim.opt.list = true
vim.opt.listchars = { ["tab"] = ">.", ["trail"] = "." , ["nbsp"] = "‸" }

-- options for netrw
vim.g.netrw_liststyle = 3       -- treestyle listing
vim.g.netrw_banner = 0          -- don't show the banner at the top (toggle with <S-i>)
vim.g.netrw_browse_split = 4    -- open files in the previous window
vim.g.netrw_winsize = 15        -- percent of window size


--
-- window specific
--

-- show line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- display the sign column
vim.opt.signcolumn = "yes"

-- visually break lines at max width
vim.opt.linebreak = true

-- show the cursor line
vim.opt.cursorline = true


--
-- buffer specific
--

-- keep the same indentation level from previous line
vim.opt.autoindent = true

-- tabs as spaces, tab size 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

-- disable modelines in favor of secure modelines
-- (see the secure modelines plugin)
vim.opt.modeline = false

-- enable undo files, disable swap files
vim.opt.undofile = true
vim.opt.swapfile = false

-- format options, describe how autoformatting is done
vim.opt.formatoptions = "tcrqnlj"

-- vim: set tw=0 fo-=r
