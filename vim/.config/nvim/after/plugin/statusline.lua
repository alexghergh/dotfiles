-- see :h status-line and :h statusline
-- see https://nihilistkitten.me/nvim-lua-statusline/
-- for colors and highlights, see after/plugin/colorscheme.lua

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
        if vim.bo.modifiable == true then
            attr = attr .. '+'
        else
            attr = attr .. '-'
        end
    end

    if vim.bo.readonly == true then
        attr = attr .. 'R'
    end

    if vim.wo.previewwindow == true then
        attr = attr .. 'P'
    end

    if attr == '' then
        return ''
    else
        return '[' .. attr .. ']'
    end
end

local function git_stats()
    -- [added, modified, removed]
    return vim.fn['sy#repo#get_stats']()
end

local function treesitter_scope()
    -- test if there are any captures under the cursor;
    -- chances are, if there are none, then we either don't have a valid
    -- treesitter parser for the current buffer, or there really are none under
    -- the cursor; in either case, don't return the scope
    --
    -- also, since the scope can get quite big, as a workaround for now,
    -- don't print it when the window width is less than 100 chars
    if next(vim.treesitter.get_captures_at_cursor()) ~= nil then
        if vim.fn.winwidth(0) > 99 then
            return vim.fn['nvim_treesitter#statusline']()
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
local function gen_section_stats(stats)
    local fmt = ''

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
        gen_section('StatusLineColor2', '%<%f', ' '),

        -- file attributes and diff stats
        gen_section('StatusLineColor2', '%k #%n %a'),
        gen_section('StatusLineColor2',
            ' [', fileencoding(), ',', filetype(), ']',
            fileattributes(),
            '%q '
        ),
        gen_section_stats(git_stats()),

        -- scope as reported by treesitter
        gen_section('StatusLineColor3', ' ', treesitter_scope()),

        -- separator between left and right sides
        '%=',

        -- right side stuff (line, column, percentage, total LOC)
        gen_section('StatusLineColor2',
            ' %-12.(%l,%c%V%)',
            '%p%% (out of %L)'
        ),
    })
end

-- set up the statusline function; also make the statusline global
vim.o.statusline = "%!luaeval('status_line()')"
vim.o.laststatus = 3
