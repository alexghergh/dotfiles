local wezterm = require('wezterm')
local act = wezterm.action
local background = require('background')

local config = wezterm.config_builder()

config.color_scheme = 'Afterglow'

config.font = wezterm.font_with_fallback({
    'JetBrains Mono',
    'Fira Code',
    'Hack',
})
config.font_size = 12
config.adjust_window_size_when_changing_font_size = false
config.warn_about_missing_glyphs = false

config.window_padding = {
    left = 5,
    right = 5,
    bottom = 5,
    top = 5,
}

config.inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.6,
}

config.foreground_text_hsb = {
    brightness = 1,
    saturation = 1,
}

-- choose random background based on day of the month
local now = os.date('*t', os.time())
math.randomseed(tonumber(now.day))
config.background = {
    table.unpack(background[math.random(1, #background)]),
}

-- IME
config.use_ime = true
config.xim_im_name = 'fcitx'

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

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
    -- send ctrl-a normally when pressing 2x ctrl-a
    {
        key = 'a',
        mods = 'LEADER|CTRL',
        action = act.SendKey({ key = 'a', mods = 'CTRL' }),
    },

    -- split vertically
    {
        key = '|',
        mods = 'LEADER|SHIFT',
        action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
    },
    -- split horizontally
    {
        key = '-',
        mods = 'LEADER',
        action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
    },

    -- switch tab
    {
        key = 't',
        mods = 'LEADER',
        action = act.ActivateKeyTable({
            name = 'activate_tab',
            one_shot = false,
        })
    },
    -- switch pane
    {
        key = 'h',
        mods = 'META',
        action = act.ActivatePaneDirection('Left'),
    },
    {
        key = 'l',
        mods = 'META',
        action = act.ActivatePaneDirection('Right'),
    },
    {
        key = 'j',
        mods = 'META',
        action = act.ActivatePaneDirection('Down'),
    },
    {
        key = 'k',
        mods = 'META',
        action = act.ActivatePaneDirection('Up'),
    },

    -- resize pane
    {
        key = 'r',
        mods = 'LEADER',
        action = act.ActivateKeyTable({
            name = 'resize_pane',
            one_shot = false,
        }),
    },

    -- show launcher
    {
        key = 's',
        mods = 'LEADER',
        action = act.ShowLauncher,
    },

    -- resize font
    {
        key = 'f',
        mods = 'LEADER',
        action = act.ActivateKeyTable({
            name = 'resize_font',
            one_shot = false,
        }),
    },
}

config.key_tables = {
    activate_tab = {
        { key = 'h', action = act.ActivateTabRelative(-1) },
        { key = 'l', action = act.ActivateTabRelative( 1) },

        { key = 'Escape', action = 'PopKeyTable' },
    },
    resize_pane = {
        { key = 'LeftArrow', action = act.AdjustPaneSize({ 'Left', 1 }) },
        { key = 'h', action = act.AdjustPaneSize({ 'Left', 1 }) },

        { key = 'RightArrow', action = act.AdjustPaneSize({ 'Right', 1 }) },
        { key = 'l', action = act.AdjustPaneSize({ 'Right', 1 }) },

        { key = 'DownArrow', action = act.AdjustPaneSize({ 'Down', 1 }) },
        { key = 'j', action = act.AdjustPaneSize({ 'Down', 1 }) },

        { key = 'UpArrow', action = act.AdjustPaneSize({ 'Up', 1 }) },
        { key = 'k', action = act.AdjustPaneSize({ 'Up', 1 }) },

        { key = 'Escape', action = act.PopKeyTable },
    },
    resize_font = {
        { key = 'k', action = act.IncreaseFontSize },
        { key = '=', action = act.IncreaseFontSize },
        { key = '+', mods = 'SHIFT', action = act.IncreaseFontSize },

        { key = 'j', action = act.DecreaseFontSize },
        { key = '-', action = act.DecreaseFontSize },
        { key = '_', mods = 'SHIFT', action = act.DecreaseFontSize },

        { key = 'r', action = act.ResetFontSize },

        { key = 'Escape', action = act.PopKeyTable },
    },
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
