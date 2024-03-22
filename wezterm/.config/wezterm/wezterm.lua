local wezterm = require('wezterm')
local action = wezterm.action

local config = wezterm.config_builder()

config.color_scheme = 'Afterglow'

config.font = wezterm.font_with_fallback({
    'JetBrains Mono',
    'Fira Code',
    'Hack'
})
config.warn_about_missing_glyphs = false

config.inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.7,
}

config.window_background_opacity = 0.95

config.default_prog = { '/usr/bin/fish', }

config.launch_menu = {
    {
        args = { 'htop' },
    },
    {
        label = 'neovim init.lua',
        args = { 'nvim', 'init.lua' },
        cwd = '/home/alex/.config/nvim/',
    }
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
        key = 'v',
        mods = 'LEADER',
        action = action.SplitHorizontal({ domain = 'CurrentPaneDomain' })
    },
    -- split vertically
    {
        key = 'h',
        mods = 'LEADER',
        action = action.SplitVertical({ domain = 'CurrentPaneDomain' })
    },
}

return config
