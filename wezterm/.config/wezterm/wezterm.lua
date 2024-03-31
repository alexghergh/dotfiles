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

config.enable_scroll_bar = true
config.min_scroll_bar_height = '2cell'
config.colors = {
    -- scroll bar color
    scrollbar_thumb = 'white',

    -- selected text color
    selection_fg = 'black',
    selection_bg = '#fffacd',

    -- change cursor color on leader key, dead key or IME 'compose' state
    compose_cursor = 'orange',
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

config.default_prog = { '/usr/bin/fish' }
config.set_environment_variables = {
    SHELL = '/usr/bin/fish',
}
config.term = 'wezterm'

config.scrollback_lines = 10000

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

config.disable_default_key_bindings = true
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
    --
    -- regular keybinds
    --

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

    -- switch pane
    { key = 'h', mods = 'META', action = act.ActivatePaneDirection('Left') },
    { key = 'l', mods = 'META', action = act.ActivatePaneDirection('Right') },
    { key = 'j', mods = 'META', action = act.ActivatePaneDirection('Down') },
    { key = 'k', mods = 'META', action = act.ActivatePaneDirection('Up') },

    -- show launcher
    { key = 'l', mods = 'LEADER', action = act.ShowLauncher },

    -- copy
    { key = 'c', mods = 'SUPER', action = act.CopyTo('Clipboard') },
    { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },
    {
        -- ctrl-c in terminal normally if nothing is selected, copy if there is
        -- see https://github.com/wez/wezterm/issues/606#issuecomment-1238029208
        key = 'c',
        mods = 'CTRL',
        action = wezterm.action_callback(function(window, pane)
            local selection_text = window:get_selection_text_for_pane(pane)
            local is_selection_active = string.len(selection_text) ~= 0
            if is_selection_active then
                window:perform_action(act.CopyTo('Clipboard'), pane)
            else
                window:perform_action(
                    act.SendKey({ key = 'c', mods = 'CTRL' }),
                    pane
                )
            end
        end),
    },

    -- paste
    { key = 'v', mods = 'SUPER', action = act.PasteFrom('Clipboard') },
    { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom('Clipboard') },
    { key = 'v', mods = 'CTRL', action = act.PasteFrom('Clipboard') },

    -- fullscreen
    { key = 'z', mods = 'LEADER', action = act.ToggleFullScreen },

    -- show debug overlay
    { key = 'd', mods = 'LEADER', action = act.ShowDebugOverlay },

    --
    -- key tables
    --

    -- pane
    {
        key = 'p',
        mods = 'LEADER',
        action = act.ActivateKeyTable({
            name = 'pane_key_table',
            timeout_milliseconds = 1000,
        }),
    },

    -- tab
    {
        key = 't',
        mods = 'LEADER',
        action = act.ActivateKeyTable({
            name = 'tab_key_table',
            one_shot = false,
        }),
    },

    -- window
    {
        key = 'w',
        mods = 'LEADER',
        action = act.ActivateKeyTable({
            name = 'window_key_table',
            one_shot = false,
        }),
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

    -- resize font
    {
        key = 'f',
        mods = 'LEADER',
        action = act.ActivateKeyTable({
            name = 'resize_font',
            one_shot = false,
        }),
    },

    -- search
    {
        key = 's',
        mods = 'LEADER',
        action = act.ActivateKeyTable({
            name = 'search_key_table',
            one_shot = false,
        }),
    },
}

config.key_tables = {
    pane_key_table = {
        -- zoom pane
        { key = 'z', action = act.TogglePaneZoomState },

        { key = 'Escape', action = 'PopKeyTable' },
    },
    tab_key_table = {
        -- activate tab
        { key = 'h', action = act.ActivateTabRelative(-1) },
        { key = 'l', action = act.ActivateTabRelative(1) },
        { key = 'j', action = act.ActivateTabRelativeNoWrap(-1) },
        { key = 'k', action = act.ActivateTabRelativeNoWrap(1) },

        -- activate by id
        { key = '1', action = act.ActivateTab(0) },
        { key = '2', action = act.ActivateTab(1) },
        { key = '3', action = act.ActivateTab(2) },
        { key = '4', action = act.ActivateTab(3) },
        { key = '5', action = act.ActivateTab(4) },
        { key = '6', action = act.ActivateTab(5) },
        { key = '7', action = act.ActivateTab(6) },
        { key = '8', action = act.ActivateTab(7) },
        { key = '9', action = act.ActivateTab(-1) },

        -- new tab
        {
            key = 't',
            action = act.Multiple({
                act.SpawnTab('CurrentPaneDomain'),
                act.PopKeyTable,
            }),
        },

        -- kill tab
        {
            key = 'w',
            action = act.Multiple({
                act.CloseCurrentTab({ confirm = true }),
                act.PopKeyTable,
            }),
        },

        { key = 'Escape', action = act.PopKeyTable },
    },
    window_key_table = {
        -- new window
        {
            key = 'n',
            action = act.Multiple({
                act.SpawnWindow,
                act.PopKeyTable,
            }),
        },

        { key = 'Escape', action = act.PopKeyTable },
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
    search_key_table = {
        -- clear scrollback buffer (what's above screen)
        {
            key = 'c',
            mods = 'CTRL|SHIFT',
            action = act.ClearScrollback('ScrollbackOnly'),
        },
        -- clear scrollback and viewport (what's currently on screen)
        {
            key = 'v',
            mods = 'CTRL|SHIFT',
            action = act.Multiple({
                act.ClearScrollback('ScrollbackAndViewport'),
                act.SendKey({ key = 'l', mods = 'CTRL' }),
            }),
        },

        -- scroll up/down
        { key = 'u', mods = 'CTRL', action = act.ScrollByPage(-0.5) },
        { key = 'd', mods = 'CTRL', action = act.ScrollByPage(0.5) },
        { key = 'b', mods = 'CTRL', action = act.ScrollByPage(-1) },
        { key = 'f', mods = 'CTRL', action = act.ScrollByPage(1) },

        { key = '/', action = act.Search('CurrentSelectionOrEmptyString') },

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
