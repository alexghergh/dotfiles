-- wrap nvim-notify's built-in notification position to avoid the cursor,
-- if the cursor position is under a notification (move the notification)
local function notify_avoid_cursor_stages(top_down)
    -- keep notify's stock stage implementation, such that open, wait, and close behavior stay unchanged
    local stage_util = require('notify.stages.util')
    local direction = top_down and stage_util.DIRECTION.TOP_DOWN or stage_util.DIRECTION.BOTTOM_UP
    local stages = require('notify.stages.fade_in_slide_out')(direction)

    -- convert the current editing cursor into the same screen-space row/col coordinates
    -- that notify uses for its float placement, then shove the target row if needed
    local function avoid(row, message)
        local win = vim.api.nvim_get_current_win()

        -- screenpos expects a 1-based column, but win_get_cursor returns a 0-based one
        local cursor = vim.api.nvim_win_get_cursor(win)
        local pos = vim.fn.screenpos(win, cursor[1], cursor[2] + 1)

        -- bail out if neovim cannot map the cursor into a visible screen position
        if not pos or pos.row == 0 or pos.col == 0 then
            return row
        end

        -- notify anchors these floats on the top-right, so infer the left edge from
        -- the editor width, message width, and the rounded border width
        local left = math.max(0, vim.o.columns - message.width - 2)
        -- screenpos is 1-based, notify rows are effectively 0-based
        local top = pos.row - 1
        -- include the border so the cursor check matches what you visually see
        local bottom = row + message.height + 1

        -- if the cursor is outside the rectangle, keep notify's original row target
        if pos.col - 1 < left or top < row or top > bottom then
            return row
        end

        -- mirror notify's own top boundary logic so the shove does not push the float
        -- into the tabline or winbar area
        local min_row = (vim.o.showtabline == 2 or (vim.o.showtabline == 1 and vim.fn.tabpagenr('$') > 1)) and 1 or 0
        if vim.wo.winbar ~= '' then
            min_row = min_row + 1
        end

        -- mirror notify's bottom boundary logic so the float stays inside the editor
        local max_row = vim.o.lines - (vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0) + 1) - message.height - 1
        -- move away from the cursor in the same vertical direction the stack already uses
        local shift = top_down and 10 or -10
        return math.min(math.max(row + shift, min_row), math.max(min_row, max_row))
    end

    -- wrap every stock stage function and only patch the row target before handing it
    -- back to notify's animator
    return vim.tbl_map(function(stage)
        return function(state, win)
            local result = stage(state, win)

            -- some stages can return nil when no placement is possible
            if not result or result.row == nil then
                return result
            end

            -- opening stages can use a plain row value, while animated stages use a
            -- spring goal table whose first item is the target row
            if type(result.row) == 'table' then
                result.row[1] = avoid(result.row[1], state.message)
            else
                result.row = avoid(result.row, state.message)
            end

            return result
        end
    end, stages)
end

return {

    -- goodies and other utilities for rainy days
    {
        'nvim-lua/plenary.nvim',
        lazy = true,
    },

    -- custom vim.ui.select implementation
    {
        'nvim-telescope/telescope-ui-select.nvim',
        config = function()
            require('telescope').load_extension('ui-select')
        end,
    },

    -- custom vim.ui.input implementation
    {
        'folke/snacks.nvim',
        opts = {
            input = {},
            styles = {
                input = {
                    row = -20,
                },
            },
        },
    },

    -- custom vim.notify implementation
    {
        'rcarriga/nvim-notify',
        opts = {
            render = 'wrapped-compact',
            fps = 60,
            top_down = false,
            max_width = function() -- dynamically calculate max width
                return math.ceil(vim.o.columns / 2)
            end,
        },
        config = function(_, opts)
            -- if the cursor is under the notification window, compute the animation
            -- as to avoid the mouse cursor; this requires high fps to work smoothly
            opts.stages = notify_avoid_cursor_stages(opts.top_down)

            require('notify').setup(opts)

            -- open past notifications in telescope
            local telescope = require('telescope')
            telescope.load_extension('notify')
            vim.keymap.set('n', '<Leader>mes', telescope.extensions.notify.notify, { desc = 'Open all vim.notify notifications' })

            -- command line option
            vim.api.nvim_create_user_command('Mes', 'Notifications', {})

            -- replace neovim's built-in notification system
            vim.notify = require('notify')
        end,
    },

    -- remember keymaps
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        opts = {
            preset = 'modern',
            delay = 400,
            win = {
                wo = {
                    winblend = 10,
                },
            },
            replace = {
                desc = {
                    { '<Plug>%((.*)%)', '%1' }, -- fix the default match pattern
                    { '<Plug>(.*)', '%1' }, -- fix the default match pattern
                },
            },
            spec = {
                -- unimpaired keymaps descriptions (these are not directly accessible to which-key
                -- since operator pending mode 'y' takes precedence; the workaround is to simply
                -- start the which-key window with <leader> + <backspace>, then these will appear
                -- normally in 'n' mode)
                { 'yob', desc = 'background color (dark / light)' },
                { 'yoc', desc = 'cursorline' },
                { 'yod', desc = 'diff (actually :diffthis / :diffoff)' },
                { 'yoh', desc = 'hlsearch' },
                { 'yoi', desc = 'ignorecase' },
                { 'yol', desc = 'listchars' },
                { 'yon', desc = 'number line' },
                { 'yor', desc = 'relativenumber' },
                { 'yos', desc = 'spell' },
                { 'yot', desc = 'colorcolumn' },
                { 'you', desc = 'cursorcolumn' },
                { 'yov', desc = 'virtualedit' },
                { 'yow', desc = 'wrap' },
                { 'yox', desc = 'cursorline + cursorcolumn' },
            },
            plugins = {
                spelling = {
                    enabled = false,
                },
            },
        },
    },
}
