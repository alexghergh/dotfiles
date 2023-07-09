--
-- statusline setup
--
-- see :h status-line and :h statusline
-- see https://nihilistkitten.me/nvim-lua-statusline/
-- for colors and highlights, see after/plugin/colorscheme.lua
--
-- API:
--   - there is a very thin API (in the form of Lua functions), between some
--     status line functionality and some plugins who provide that
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
--      - for other parts of the statusline:
--          - StatusLine: the default color which comes bundled in neovim, can
--            be overriden for a nicer default (acts as a reset in the
--            statusline)
--          - StatusLineColor1: for the left and right sides that contain text
--          - StatusLineColor2: for the middle part that acts as a separator and
--            only contains the current cursor scope
--

--
-- helper functions
--
local function fileencoding()
    if vim.bo.fileencoding == '' then
        return 'enc?'
    else
        return vim.bo.fileencoding
    end
end

local function filetype()
    if vim.bo.filetype == '' then
        return 'ft?'
    else
        return vim.bo.filetype
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

local function treesitter_scope()
    -- since the scope can get quite big, don't print it when the window width
    -- is less than 120 chars
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
-- see github.com/nihilistkitten/dotfiles/blob/main/nvim/lua/statusline.lua
function status_line()
    return table.concat({
        -- filename (truncate if too long)
        gen_section('StatusLineColor1', '%<%f', ' '),

        -- file attributes
        gen_section('StatusLineColor1', '%k #%n%a'),
        gen_section('StatusLineColor1',
            ' ', fileencoding(), ',', filetype(), ' ',
            fileattributes(),
            '%q', ' '
        ),

        -- diff stats
        ' ', gen_section_diff_stats(), '|',

        -- scope as reported by treesitter
        gen_section('StatusLineColor2', ' ', treesitter_scope()),

        -- separator between left and right sides
        '%=',

        -- right side stuff (line, column, percentage, total LOC)
        gen_section('StatusLineColor1',
            ' ',
            '%-12.(%l,%c%V%)',
            '%p%% (out of %L)'
        ),
    })
end

-- set up the statusline function; also make the statusline global
vim.o.statusline = "%!luaeval('status_line()')"
vim.o.laststatus = 3
