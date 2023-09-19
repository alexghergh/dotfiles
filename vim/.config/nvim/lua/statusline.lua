--
-- statusline setup
--
-- see :h status-line and :h statusline
-- see https://nihilistkitten.me/nvim-lua-statusline/
-- for colors and highlights, see lua/colorscheme.lua
-- for the API functions, see lua/init_plugins.lua
--
-- API:
--   - there is a very thin API (in the form of global Lua functions), between
--     some status line functionality and some plugins which provide that
--     functionality, as the status line itself cannot possibly know (and
--     _should not know_), what plugins are installed
--
-- The API is as follows:
--   - functions:
--      - DiffStats(): should return a table with 3 number values in the form
--        "[ added, removed, modified ]";
--      - CursorScope(): should return a string, or empty if no treesitter
--        parser for the buffer
--      - BranchInfo(): should return a string, or empty if no information
--   - highlight groups:
--      - for DiffStats(), the statusline understands 3 highlight groups:
--          - StatusLineDiffAdd
--          - StatusLineDiffDelete
--          - StatusLineDiffChange
--      - for other parts of the statusline, the following should be defined:
--          - StatusLine: the default color which comes bundled in neovim, can
--            be overriden for a nicer default (acts as a reset in the
--            statusline)
--          - StatusLineColor1: for the outermost layer of text
--          - StatusLineColor2: for the next layer of text
--          - StatusLineColor3: for the innermost layer of text (the middle part
--            of the screen in vim, which acts as separator between the left and
--            right sides)
--          - StatusLineSeparator12: separator color for the first 2 layers
--          - StatusLineSeparator23: separator color for the last 2 layers
--

--
-- mode information
-- see https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/utils/mode.lua
--
local modes_map = {
    ['n']     = 'NORMAL',
    ['no']    = 'O-PENDING',
    ['nov']   = 'O-PENDING',
    ['noV']   = 'O-PENDING',
    ['no\22'] = 'O-PENDING',
    ['niI']   = 'NORMAL',
    ['niR']   = 'NORMAL',
    ['niV']   = 'NORMAL',
    ['nt']    = 'NORMAL',
    ['ntT']   = 'NORMAL',
    ['v']     = 'VISUAL',
    ['vs']    = 'VISUAL',
    ['V']     = 'V-LINE',
    ['Vs']    = 'V-LINE',
    ['\22']   = 'V-BLOCK',
    ['\22s']  = 'V-BLOCK',
    ['s']     = 'SELECT',
    ['S']     = 'S-LINE',
    ['\19']   = 'S-BLOCK',
    ['i']     = 'INSERT',
    ['ic']    = 'INSERT',
    ['ix']    = 'INSERT',
    ['R']     = 'REPLACE',
    ['Rc']    = 'REPLACE',
    ['Rx']    = 'REPLACE',
    ['Rv']    = 'V-REPLACE',
    ['Rvc']   = 'V-REPLACE',
    ['Rvx']   = 'V-REPLACE',
    ['c']     = 'COMMAND',
    ['cv']    = 'EX',
    ['ce']    = 'EX',
    ['r']     = 'REPLACE',
    ['rm']    = 'MORE',
    ['r?']    = 'CONFIRM',
    ['!']     = 'SHELL',
    ['t']     = 'TERMINAL',
}

--
-- helper functions
--
local function sep(style)
    -- 'style' can be either 'arrow' or 'gaps'
    if style == 'arrow' then
        return {
            LSIDE_FULL  = '',
            LSIDE_EMPTY = '',
            RSIDE_FULL  = '',
            RSIDE_EMPTY = '',
        }
    elseif style == 'gaps' then
        return {
            LSIDE_FULL  = '', -- this might not render properly in certain fonts
            LSIDE_EMPTY = '\\',
            RSIDE_FULL  = '', -- this might not render properly in certain fonts
            RSIDE_EMPTY = '/',
        }
    else
        return {
            LSIDE_FULL  = '',
            LSIDE_EMPTY = '|',
            RSIDE_FULL  = '',
            RSIDE_EMPTY = '|',
        }
    end
end

local function current_mode_color()
    return 'StatusLineColor1'
end

local function current_mode_color_sep()
    return 'StatusLineSeparator12'
end

local function current_mode_text()
    return modes_map[vim.fn.mode()] or 'None'
end

local function branch_info()
    -- see API above for BranchInfo()
    if BranchInfo ~= nil then
        return BranchInfo()
    else
        return ''
    end
end

local function fileattributes()
    local attr = ''

    if vim.bo.modified == true then
        attr = attr .. '+'
    end

    if vim.bo.modifiable == false then
        attr = attr .. '-'
    end

    if vim.bo.readonly == true then
        attr = attr .. 'R'
    end

    if vim.wo.previewwindow == true then
        attr = attr .. 'P'
    end

    if attr ~= '' then
        return '[' .. attr .. ']'
    end
    return ''
end

local function filetype()
    if vim.bo.filetype == '' then
        return 'ft?'
    else
        return vim.bo.filetype
    end
end

local function fileencoding()
    if vim.bo.fileencoding == '' then
        return 'enc?'
    else
        return vim.bo.fileencoding
    end
end

local function treesitter_scope()
    -- since the scope can get quite big, don't print it when the window width
    -- is less than 100 chars
    if vim.fn.winwidth(0) > 99 then
        -- see API above for CursorScope()
        if CursorScope ~= nil then
            return CursorScope()
        end
    end
    return ''
end

local function longlines()
    -- don't display if buffer too big
    if vim.api.nvim_buf_line_count(0) > 10000 then
        return ''
    end
    -- TODO some caching mechanism here would be good if it turns out to be too
    -- slow (either with a timer, using a closure value, or running async via
    -- the event loop somehow); see vim.loop
    -- TODO to profile with plenary.nvim

    local str = ''
    local threshold
    local long_lines = {}
    local spaces = vim.fn['repeat'](' ', vim.bo.tabstop)

    if vim.bo.textwidth ~= 0 then
        threshold = vim.bo.textwidth
    else
        threshold = 80   -- sane default
        str = str .. '~' -- mark that &tw is not set
    end

    -- iterate lines in the buffer, and save long lines in list
   for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
        local len = #vim.fn.substitute(line, '\t', spaces, 'g') -- expand tabs
        if len > threshold then
            table.insert(long_lines, #line)
        end
    end

    -- sort list of long lines
    table.sort(long_lines)

    -- calculate median
    local median = 0
    local mid = math.floor(#long_lines / 2) + 1
    if #long_lines ~= 0 then
        if #long_lines % 2 == 1 then
            median = long_lines[mid]
        else
            median = (long_lines[mid - 1] + long_lines[mid]) / 2
        end
    end

    local max = vim.fn.max(long_lines)

    str = str .. '[#' .. #long_lines .. ' ^' .. max .. ' m' .. median .. ']'
    return str
end

--
-- highlights
--

-- generate a highlighted section, based on the highlighting group and the
-- variadic strings passed as parameters
local function gen_section(highlight_group, ...)
    local fmt = '%#' .. highlight_group .. '#'
    for _, arg in ipairs({ ... }) do
        fmt = fmt .. arg
    end
    fmt = fmt .. '%#StatusLine#' -- acts as a clear / reset to default
    return fmt
end

-- generate a 'special' highlighted section, for the version control diff stats
local function gen_section_diff_stats()
    local fmt = ''
    local stats = ''

    -- see API above for DiffStats()
    if DiffStats ~= nil then
        stats = DiffStats()
    else
        return ''
    end

    if stats[1] > 0 then
        fmt = fmt .. '%#StatusLineDiffAdd#+' .. stats[1] .. ' '
    end

    if stats[3] > 0 then
        fmt = fmt .. '%#StatusLineDiffDelete#-' .. stats[3] .. ' '
    end

    if stats[2] > 0 then
        fmt = fmt .. '%#StatusLineDiffChange#~' .. stats[2] .. ' '
    end

    fmt = fmt .. '%#StatusLine#' -- acts as a clear / reset to default
    return fmt
end

-- TODO
-- integrate vim.diagnostic.get() for diagnostics count
-- nvim_treesitter with more options
-- branch name information
-- see github.com/nihilistkitten/dotfiles/blob/main/nvim/lua/statusline.lua
function StatusLine()
    -- see sep() above
    local style = 'gaps'

    return table.concat({
        --
        -- left side
        --

        -- current mode
        gen_section(current_mode_color(), ' ', current_mode_text(), ' '),
        gen_section(current_mode_color_sep(), sep(style).LSIDE_FULL, ' '),

        -- VCS branch info
        gen_section('StatusLineColor2', ' ', '', branch_info(), ' '),
        gen_section('StatusLineSeparator23', sep(style).LSIDE_FULL, ' '),

        -- diff stats
        gen_section_diff_stats(),
        gen_section('StatusLineColor3', sep(style).LSIDE_EMPTY, ' '),

        -- scope as reported by treesitter
        -- gen_section('StatusLineColor3', treesitter_scope()),
        -- gen_section('StatusLineColor3', ' ', sep(style).LSIDE_EMPTY, ' '),

        -- separator
        '%=',

        --
        -- middle side
        --

        -- filename + path
        gen_section('StatusLineColor3', '%<%f'),

        -- buffer number + arg list
        gen_section('StatusLineColor3', ' ', '#%n%a'),

        -- file attributes (modified, readonly etc.)
        gen_section('StatusLineColor3', ' ', fileattributes()),

        -- separator
        '%=',

        --
        -- right side
        --

        -- file encoding + type
        gen_section('StatusLineColor3', ' ', sep(style).RSIDE_EMPTY, ' '),
        gen_section('StatusLineColor3', filetype()),
        gen_section('StatusLineColor3', ' ', sep(style).RSIDE_EMPTY, ' '),
        gen_section('StatusLineColor3', fileencoding()),
        ' ',

        gen_section('StatusLineSeparator23', sep(style).RSIDE_FULL),

        -- long lines (total number, median, longest)
        gen_section('StatusLineColor2', ' ', longlines()),
        gen_section('StatusLineColor2', ' ', sep(style).RSIDE_EMPTY, ' '),

        -- line, column, percentage, total LOC
        gen_section('StatusLineColor2', '%(%l:%c%V%)'),
        gen_section('StatusLineColor2', ' ', sep(style).RSIDE_EMPTY, ' '),
        gen_section('StatusLineColor2', '%p%% (out of %L)'),
        gen_section('StatusLineSeparator12', ' ', sep(style).RSIDE_FULL),
    })
end

-- set up the statusline function; also make the statusline global
vim.o.statusline = "%!luaeval('StatusLine()')"
vim.o.laststatus = 3
