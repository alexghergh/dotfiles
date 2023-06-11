--
-- neovim settings
--

--
-- global
--

-- python3 program, allows neovim to work in virtual environments;
-- set inside $XDG_CONFIG_HOME/zsh/.zsh_other/.zsh_env_vars
if vim.env.VIM_PYTHON3_HOST_PROG ~= nil then
    vim.g.python3_host_prog = vim.env.VIM_PYTHON3_HOST_PROG
end

-- wrap line prefix
vim.opt.showbreak = '↪ '

-- amount of lines to keep above and below the cursor at all times
vim.opt.scrolloff = 7

-- smart search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- highlight matched strings as typing occurs
vim.opt.incsearch = true

-- allow neovim to copy and paste directly from the system clipboard
vim.opt.clipboard:append { 'unnamedplus' }

-- don't unload buffers when switching, just hide them
vim.opt.hidden = true

-- show diffs in vertical splits by default
vim.opt.diffopt:append { 'vertical' }

-- update every 50 milliseconds after not typing anything
vim.opt.updatetime = 50

-- preview menu options for autocompletion
vim.opt.completeopt = { 'menuone', 'noinsert', 'preview' }

-- show the total number of substitutions
vim.opt.report = 0

-- enable true 24-bit terminal colors
vim.opt.termguicolors = true
vim.opt.background = 'dark'

-- ignore certain files when opening buffers from inside neovim
vim.opt.wildignore:append { '*.o', '*.obj', '**/.git/*', '*.swp', '*.pyc', '*.class', '**/node_modules/*', '*.bak' }
vim.opt.wildmode = 'lastused:longest:full,full'

-- incremental live completion
vim.opt.inccommand = 'nosplit'

-- prefer splitting windows below or to the right
vim.opt.splitbelow = true
vim.opt.splitright = true

-- add directories upwards as search path
vim.opt.path:append { '**' }

-- show tab characters, line-endings
vim.opt.list = true
vim.opt.listchars = { ['tab'] = '>.', ['trail'] = '.' , ['nbsp'] = '‸' }

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

-- display the sign column, automatically resizing to accomodate between 1 and 4
-- signs (by default, a 'sign' takes 2 characters/columns, so 4 signs will take
-- a total of 8 columns)
vim.opt.signcolumn = 'auto:1-4'

-- visually break lines at max width
vim.opt.linebreak = true

-- show the cursor line
vim.opt.cursorline = true

-- all folds are open by default
vim.opt.foldlevel = 9999

-- show folding column
vim.opt.foldcolumn = '1'

-- minimum lines to create fold
vim.opt.foldminlines = 3

-- set max fold level
vim.opt.foldnestmax = 4


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
vim.opt.formatoptions = 'tcrqnlj'

-- vim: set tw=0 fo-=r ft=lua
