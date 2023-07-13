--
-- statusline setup
--
-- see :h status-line and :h statusline
-- see https://nihilistkitten.me/nvim-lua-statusline/
-- for colors and highlights, see after/plugin/colorscheme.lua
--
-- API:
--   - there is a very thin API (in the form of Lua functions), between some
--     status line functionality and some plugins which provide that
--     functionality, as the status line itself cannot possibly know (and
--     _should not know_), what plugins are installed
--   - careful!, so as to not define the functions below multiple times, or they
--     will get overriden by the last plugin (lua file, alphabetically) in which
--     that function is defined
--
-- The API is as follows:
--   - functions:
--      - diff_stats(): provided as a Lua function by whatever diff plugin is
--        installed (should be defined in after/plugin); should always return a
--        table with 3 number values in the form "[ added, removed, modified ]";
--      - cursor_scope(): provided as a Lua function by whatever scope plugin is
--        installed (should be defined in after/plugin); should always return
--        a string (for cases where there is no treesitter parser for the
--        buffer, return an empty string)
--   - highlight groups:
--      - for diff_stats(), the statusline understands 3 highlight groups:
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
    return vim.fn.system('git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d "\\n"')
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
        -- see API above for cursor_scope()
        if cursor_scope ~= nil then
            return cursor_scope()
        end
    end
    return ''
end

--
-- highlights
--

-- generate a highlighted section, based on the highlighting group and the
-- variadic strings passed as parameters
local function gen_section(highlight_group, ...)
    local fmt = '%#' .. highlight_group .. '#'
    for i, arg in ipairs({...}) do
        fmt = fmt .. arg
    end
    fmt = fmt .. '%#StatusLine#' -- acts as a clear / reset to default
    return fmt
end

-- generate a 'special' highlighted section, for the version control diff stats
local function gen_section_diff_stats()
    local fmt = ''
    local stats = ''

    -- see API above for diff_stats()
    if diff_stats ~= nil then
        stats = diff_stats()
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
function status_line()
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

        -- line, column, percentage, total LOC
        gen_section('StatusLineSeparator23', sep(style).RSIDE_FULL),
        gen_section('StatusLineColor2', ' ', '%(%l:%c%V%)'),
        gen_section('StatusLineColor2', ' ', sep(style).RSIDE_EMPTY, '  '),
        gen_section('StatusLineColor2', '%p%% (out of %L)'),
        gen_section('StatusLineSeparator12', ' ', sep(style).RSIDE_FULL),
    })
end

-- set up the statusline function; also make the statusline global
vim.o.statusline = "%!luaeval('status_line()')"
vim.o.laststatus = 3
