local wezterm = require('wezterm')
local action = wezterm.action

local config = wezterm.config_builder()

config.color_scheme = 'Afterglow'

config.font = wezterm.font_with_fallback({
    'JetBrains Mono',
    'Fira Code',
    'Hack',
})
config.warn_about_missing_glyphs = false

config.inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.6,
}

config.window_background_opacity = 0.95

config.default_prog = { '/usr/bin/fish', }
config.set_environment_variables = {
    SHELL = '/usr/bin/fish',
}

config.launch_menu = {
    {
        args = { 'htop' },
    },
    {
        label = 'neovim - init.lua',
        args = { 'nvim', 'init.lua' },
        cwd = '/home/alex/.config/nvim/',
    },
    {
        label = 'neovim - keymaps.lua',
        args = { 'nvim', 'keymaps.lua' },
        cwd = '/home/alex/.config/nvim/lua/core',
    },
    {
        label = 'tmux - tmux.conf',
        args = { 'nvim', 'tmux.conf' },
        cwd = '/home/alex/.config/tmux/',
    },
    {
        label = 'wezterm - wezterm.lua',
        args = { 'nvim', 'wezterm.lua' },
        cwd = '/home/alex/.config/wezterm/',
    },
    {
        label = 'fish - conf.d/',
        args = { 'nvim', 'conf.d/' },
        cwd = '/home/alex/.config/fish/',
    },
    {
        label = 'fish - abbr.fish',
        args = { 'nvim', 'conf.d/abbr.fish' },
        cwd = '/home/alex/.config/fish/',
    },
}

-- IME
config.use_ime = true
config.xim_im_name = 'fcitx'

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
    -- send ctrl-a normally when pressing 2x ctrl-a
    {
        key = 'a',
        mods = 'LEADER|CTRL',
        action = action.SendKey({ key = 'a', mods = 'CTRL' })
    },

    -- split vertically
    {
        key = '|',
        mods = 'LEADER|SHIFT',
        action = action.SplitHorizontal({ domain = 'CurrentPaneDomain' })
    },
    -- split horizontally
    {
        key = '-',
        mods = 'LEADER',
        action = action.SplitVertical({ domain = 'CurrentPaneDomain' })
    },

    -- switch tab
    {
        key = 't',
        mods = 'LEADER',
        action = action.ActivateKeyTable({
            name = 'activate_tab',
            one_shot = false,
        })
    },
    -- switch pane
    {
        key = 'h',
        mods = 'META',
        action = action.ActivatePaneDirection('Left'),
    },
    {
        key = 'l',
        mods = 'META',
        action = action.ActivatePaneDirection('Right'),
    },
    {
        key = 'j',
        mods = 'META',
        action = action.ActivatePaneDirection('Down'),
    },
    {
        key = 'k',
        mods = 'META',
        action = action.ActivatePaneDirection('Up'),
    },

    -- resize pane
    {
        key = 'r',
        mods = 'LEADER',
        action = action.ActivateKeyTable({
            name = 'resize_pane',
            one_shot = false,
        }),
    },

    -- show launcher
    {
        key = 's',
        mods = 'LEADER',
        action = action.ShowLauncher,
    },

    -- resize font
    {
        key = 'f',
        mods = 'LEADER',
        action = action.ActivateKeyTable({
            name = 'resize_font',
            one_shot = false,
        }),
    },
}

config.key_tables = {
    activate_tab = {
        { key = 'h', action = action.ActivateTabRelative(-1) },
        { key = 'l', action = action.ActivateTabRelative( 1) },

        { key = 'Escape', action = 'PopKeyTable' },
    },
    resize_pane = {
        { key = 'LeftArrow', action = action.AdjustPaneSize({ 'Left', 1 }) },
        { key = 'h', action = action.AdjustPaneSize({ 'Left', 1 }) },

        { key = 'RightArrow', action = action.AdjustPaneSize({ 'Right', 1 }) },
        { key = 'l', action = action.AdjustPaneSize({ 'Right', 1 }) },

        { key = 'DownArrow', action = action.AdjustPaneSize({ 'Down', 1 }) },
        { key = 'j', action = action.AdjustPaneSize({ 'Down', 1 }) },

        { key = 'UpArrow', action = action.AdjustPaneSize({ 'Up', 1 }) },
        { key = 'k', action = action.AdjustPaneSize({ 'Up', 1 }) },

        { key = 'Escape', action = 'PopKeyTable' },
    },
    resize_font = {
        { key = 'j', action = action.IncreaseFontSize },
        { key = '=', action = action.IncreaseFontSize },
        { key = '+', mods='SHIFT', action = action.IncreaseFontSize },

        { key = 'k', action = action.DecreaseFontSize },
        { key = '-', action = action.DecreaseFontSize },
        { key = '_', mods='SHIFT', action = action.DecreaseFontSize },

        { key = 'r', action = action.ResetFontSize },

        { key = 'Escape', action = 'PopKeyTable' },
    }
}

-- display activation key table
wezterm.on('update-right-status', function(window, _)
    local name = window:active_key_table()
    if name then
        name = 'KEY TABLE: ' .. name
    end
    window:set_right_status(name or '')
end)

return config
