local M = {}

local wezterm = require('wezterm')

function M.move_cursor(key, direction)
    return {
        key = key,
        mods = 'ALT',
        action = wezterm.action_callback(function(window, pane)
            if pane:get_user_vars().IS_NVIM == 'true' then
                -- keep this the same as neovim (see lua/modules/smart-splits.lua)
                window:perform_action({
                    SendKey = { key = key, mods = 'ALT' },
                }, pane)
            else
                window:perform_action({
                    ActivatePaneDirection = direction,
                }, pane)
            end
        end),
    }
end

function M.resize_pane(key, direction)
    return {
        key = key,
        action = wezterm.action_callback(function(window, pane)
            if pane:get_user_vars().IS_NVIM == 'true' then
                -- keep these the same as neovim (see lua/modules/smart-splits.lua)
                window:perform_action({ SendKey = { key = ' ' } }, pane)
                window:perform_action({ SendKey = { key = 'w' } }, pane)
                window:perform_action({ SendKey = { key = key } }, pane)
            else
                window:perform_action(
                    { AdjustPaneSize = { direction, 1 } },
                    pane
                )
            end
        end),
    }
end

return M
