--
-- neovim settings
--

--
-- global
--

-- python3 program, allows neovim to work in virtual environments
vim.g.python3_host_prog = '/usr/bin/python3'

-- wrap line prefix
vim.opt.showbreak = '↪ '

-- break indentation
vim.opt.breakindent = true

-- amount of lines to keep above and below the cursor at all times
vim.opt.scrolloff = 7

-- smart search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- highlight matched strings as typing occurs
vim.opt.incsearch = true

-- don't unload buffers when switching, just hide them
vim.opt.hidden = true

-- show diffs in vertical splits by default
vim.opt.diffopt:append({ 'vertical' })

-- update every 50 milliseconds after not typing anything
vim.opt.updatetime = 50

-- preview menu options for autocompletion
vim.opt.completeopt = { 'menuone', 'preview' }

-- show the total number of substitutions
vim.opt.report = 0

-- enable true 24-bit terminal colors
vim.opt.termguicolors = true
vim.opt.background = 'dark'

-- ignore certain files when opening buffers from inside neovim
vim.opt.wildignore:append({
    '*.o',
    '*.obj',
    '**/.git/*',
    '*.swp',
    '*.pyc',
    '*.class',
    '**/node_modules/*',
    '*.bak',
})
vim.opt.wildmode = 'longest:full,full'

-- enable fuzzy command-line completion
vim.opt.wildoptions:append({ 'fuzzy' })

-- incremental live completion
vim.opt.inccommand = 'nosplit'

-- prefer splitting windows below or to the right
vim.opt.splitbelow = true
vim.opt.splitright = true

-- add directories upwards as search path
vim.opt.path:append({ '**' })

-- show tab characters, line-endings, leading space, wrap chars
vim.opt.list = true
vim.opt.listchars = {
    ['tab'] = '>·',
    ['trail'] = '·',
    ['nbsp'] = '‸',
    ['leadmultispace'] = '·  |',
    ['extends'] = '→',
    ['precedes'] = '←',
}

-- rounded borders
vim.opt.winborder = 'rounded'

-- display unprintable characters as hex numbers
-- show characters for line too long at the bottom of the screen
vim.opt.display = { 'lastline', 'uhex' }
vim.opt.fillchars = { ['lastline'] = '>' }

-- make statusline global
vim.opt.laststatus = 3

--
-- window specific
--

-- show line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- display the sign column, automatically resizing to accomodate between 2 and 4
-- signs (by default, a 'sign' takes 2 characters/columns, so 4 signs will take
-- a total of 8 columns); min 2 for LSP and git gutter
vim.opt.signcolumn = 'auto:2-4'

-- visually break lines at max width
vim.opt.linebreak = true

-- show a colored column at position textwidth + 1
vim.opt.colorcolumn = '+1'

-- all folds are open by default
vim.opt.foldlevel = 9999

-- show folding column
vim.opt.foldcolumn = '1'

-- minimum lines to create fold
vim.opt.foldminlines = 3

-- set max fold level
vim.opt.foldnestmax = 4

-- display cursorline
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

-- disable modelines
vim.opt.modeline = false

-- enable undo files, disable swap files
vim.opt.undofile = true
vim.opt.swapfile = false

-- format options, describe how autoformatting is done
vim.opt.formatoptions = 'tcrqnlj'
