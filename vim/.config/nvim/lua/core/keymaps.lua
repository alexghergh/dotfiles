--
-- keymappings
--
-- see :h vim.keymap
-- see :h nvim_set_keymap
--
-- notes:
--   - remap is false by default in vim.keymap.set
--   - other plugin-specific mappings are found in lua/modules/*.lua
--

--
-- quality-of-life keymaps
--

-- let j and k move inside a line visually even if it gets wrapped
-- for both normal and visual modes; if there is a count prefixed to the
-- command, then revert back to normal (so line numbers work correctly)
vim.keymap.set({ 'n', 'x' }, 'j', "v:count ? 'j' : 'gj'", { expr = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count ? 'k' : 'gk'", { expr = true })

-- make <C-w> and <C-u> undo-friendly (see :h i_CTRL-G_u)
vim.keymap.set('i', '<C-w>', '<C-g>u<C-w>')
vim.keymap.set('i', '<C-u>', '<C-g>u<C-u>')

-- add undo break points after common separators and delimiters while typing
for _, key in ipairs({ ',', '.', ';', ':', '?', '!', '(', ')', '[', ']', '{', '}' }) do
    vim.keymap.set('i', key, '<C-g>u' .. key)
end

-- since we remapped <Leader> to Space, just unmap Space, to avoid the cursor
-- moving right "feature"
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>')

-- make delete just... delete (:h "_)
vim.keymap.set({ 'n', 'v' }, '<Leader>d', '"_d', { desc = 'Delete without register' })
vim.keymap.set({ 'n', 'v' }, '<Leader>D', '"_D', { desc = 'Delete without register' })

--
-- navigation/code-flow/code movement keymaps
--

-- switch to last file
vim.keymap.set('n', '<Leader>o', '<C-^>', { desc = 'Switch to last file' })

-- navigate tags (mnemonic Switch Tag)
vim.keymap.set('n', '<Leader>st', '<C-]>', { desc = 'Navigate to tag' })

-- this remaps the tags navigation of [t and ]t to tab navigation
-- tab navigation can also be achieved through gt and gT
-- you can still access tag navigation through :tnext and :tprevious
vim.keymap.set('n', ']t', '<Cmd>tabnext<CR>', { desc = 'Next tab' })
vim.keymap.set('n', '[t', '<Cmd>tabprevious<CR>', { desc = 'Previous tab' })

-- in insert mode, move cursor left/right
vim.keymap.set('i', '<A-h>', '<Left>', { desc = 'Move cursor left in insert mode' })
vim.keymap.set('i', '<A-l>', '<Right>', { desc = 'Move cursor right in insert mode' })

-- in insert mode, move line up/down (similar to unimpaired's [e and ]e in normal mode)
vim.keymap.set('i', '<A-j>', function()
    local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
    local last = vim.api.nvim_buf_line_count(0)
    -- stylua: ignore
    if row >= last then return end

    -- keep each line movement a separate undo position
    local keys = vim.api.nvim_replace_termcodes('<C-g>u', true, false, true)
    vim.api.nvim_feedkeys(keys, 'n', false)

    local lines = vim.api.nvim_buf_get_lines(0, row - 1, row + 1, true)
    -- stylua: ignore
    if #lines < 2 then return end

    vim.api.nvim_buf_set_lines(0, row - 1, row + 1, true, { lines[2], lines[1] })
    vim.api.nvim_win_set_cursor(0, { row + 1, math.min(col, #lines[1]) })
end, { desc = 'Move current line down in insert mode' })

vim.keymap.set('i', '<A-k>', function()
    local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
    -- stylua: ignore
    if row == 1 then return end

    local lines = vim.api.nvim_buf_get_lines(0, row - 2, row, true)
    -- stylua: ignore
    if #lines < 2 then return end

    -- keep each line movement a separate undo position
    local keys = vim.api.nvim_replace_termcodes('<C-g>u', true, false, true)
    vim.api.nvim_feedkeys(keys, 'n', false)

    vim.api.nvim_buf_set_lines(0, row - 2, row, true, { lines[2], lines[1] })
    vim.api.nvim_win_set_cursor(0, { row - 1, math.min(col, #lines[2]) })
end, { desc = 'Move current line up in insert mode' })

--
-- window keymaps
--
vim.keymap.set('n', '<Leader>wk', '<Cmd>resize -10<CR>', { desc = 'Resize window height (-10)' })
vim.keymap.set('n', '<Leader>wj', '<Cmd>resize +10<CR>', { desc = 'Resize window height (+10)' })
vim.keymap.set('n', '<Leader>wh', '<Cmd>vertical resize -10<CR>', { desc = 'Resize window width (-10)' })
vim.keymap.set('n', '<Leader>wl', '<Cmd>vertical resize +10<CR>', { desc = 'Resize window width (+10)' })
vim.keymap.set('n', '<Leader>w=', '<Cmd>wincmd =<CR>', { desc = 'Make windows equal' })
vim.keymap.set('n', '<C-w><Leader>o', '<C-w><C-^>', { desc = 'Split and edit alternate file' })

--
-- diagnostics/quickfix/location lists keymaps
-- see lua/core/diagnostics.lua for other diagnostics settings
-- see :h vim.diagnostic
--

-- show diagnostics in a floating window (mnemonic Diagnostics Show)
vim.keymap.set('n', '<Leader>ds', vim.diagnostic.open_float, { desc = 'Open diagnostic window' })

-- quick fix list and location list open / close; although location list is per-window,
-- we're just trying to toggle an existing one, without trying too hard to find all open windows
vim.keymap.set('n', '<leader>lq', function()
    local qf = vim.fn.getqflist({ size = 0, winid = 0 })

    -- close the existing quickfix window if it is already visible
    if qf.winid ~= 0 then
        local ok, err = pcall(vim.cmd.cclose)
        if not ok and err then
            vim.notify(err, vim.log.levels.ERROR)
        end
        return
    end

    -- avoid opening an empty quickfix pane
    if qf.size == 0 then
        vim.notify('quickfix list is empty', vim.log.levels.INFO)
        return
    end

    -- :copen moves the cursor into quickfix, so move the cursor back; since
    -- quickfix items movement can be done by ]q and [q, there should be no
    -- need to actually _be_ in the quickfix window with the cursor
    local current_win = vim.api.nvim_get_current_win()
    local ok, err = pcall(vim.cmd.copen)
    if not ok and err then
        vim.notify(err, vim.log.levels.ERROR)
        return
    end

    if vim.api.nvim_win_is_valid(current_win) then
        vim.api.nvim_set_current_win(current_win)
    end
end, { desc = 'Open / close quickfix list' })

vim.keymap.set('n', '<leader>ll', function()
    -- location lists are per-window, so this only toggles the current window's list
    local ll = vim.fn.getloclist(0, { size = 0, winid = 0 })

    -- close the current window's location list if it is already visible
    if ll.winid ~= 0 then
        local ok, err = pcall(vim.cmd.lclose)
        if not ok and err then
            vim.notify(err, vim.log.levels.ERROR)
        end
        return
    end

    -- avoid opening an empty location list pane
    if ll.size == 0 then
        vim.notify('location list is empty', vim.log.levels.INFO)
        return
    end

    -- lopen moves the cursor into the location list, so restore the previous window
    local current_win = vim.api.nvim_get_current_win()
    local ok, err = pcall(vim.cmd.lopen)
    if not ok and err then
        vim.notify(err, vim.log.levels.ERROR)
        return
    end

    if vim.api.nvim_win_is_valid(current_win) then
        vim.api.nvim_set_current_win(current_win)
    end
end, { desc = 'Open / close location list (per window)' })

--
-- command-line keymaps
--

-- for when you REALLY want to save that buffer
vim.keymap.set('c', 'w!!', 'w !sudo tee % > /dev/null')

-- expand file and working-directory paths directly while typing in insert or command modes (Dir / File / Pwd)
-- this inserts undo-blocks in order to allow easy deletion of the whole path element inserted
-- stylua: ignore
local path_maps = {
    { lhs = '%%d', get_path = function() return vim.fn.expand('%:h') .. '/' end, desc = "Insert current file's absolute path" },
    { lhs = '%%f', get_path = function() return vim.fn.expand('%:t') end, desc = 'Insert current file name' },
    { lhs = '%%p', get_path = function() return vim.fn.getcwd() .. '/' end, desc = 'Insert current working directory' },
}
for _, path in ipairs(path_maps) do
    vim.keymap.set('i', path.lhs, function()
        local text = path.get_path()
        return '<C-g>u' .. text .. '<C-g>u'
    end, { expr = true, replace_keycodes = true, desc = path.desc })

    vim.keymap.set('c', path.lhs, function()
        if vim.fn.getcmdtype() ~= ':' then
            return path.lhs
        end

        local text = path.get_path()
        return text
    end, { expr = true, desc = path.desc })
end

--
-- terminal keymaps
--

-- escape insert mode in terminal windows
vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>', { desc = 'Exit terminal insert mode' })
