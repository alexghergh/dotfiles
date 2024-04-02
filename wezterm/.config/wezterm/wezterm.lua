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
    { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection('Left') },
    { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection('Right') },
    { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection('Down') },
    { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection('Up') },

    -- show launcher
    { key = 'l', mods = 'LEADER', action = act.ShowLauncher },

    -- copy
    { key = 'c', mods = 'SUPER', action = act.CopyTo('Clipboard') },
    { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },
    {
        key = 'c',
        mods = 'CTRL',
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ''
            if has_selection then
                window:perform_action(act.CopyTo('Clipboard'), pane)
                window:perform_action(act.ClearSelection, pane)
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
    -- { key = 'v', mods = 'CTRL', action = act.PasteFrom('Clipboard') },

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

    -- scrollback + search
    {
        key = 's',
        mods = 'LEADER',
        action = act.ActivateKeyTable({
            name = 'scrollback_key_table',
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
            key = 'n',
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
        { key = 'j', action = act.DecreaseFontSize },
        { key = '-', action = act.DecreaseFontSize },
        { key = '_', mods = 'SHIFT', action = act.DecreaseFontSize },

        { key = 'k', action = act.IncreaseFontSize },
        { key = '=', action = act.IncreaseFontSize },
        { key = '+', mods = 'SHIFT', action = act.IncreaseFontSize },

        { key = 'r', action = act.ResetFontSize },

        { key = 'Escape', action = act.PopKeyTable },
    },
    scrollback_key_table = {
        -- kill scrollback buffer (what's above screen)
        {
            key = 'k',
            mods = 'CTRL|SHIFT',
            action = act.ClearScrollback('ScrollbackOnly'),
        },
        -- clear scrollback and viewport (what's currently on screen)
        {
            key = 'l',
            mods = 'CTRL|SHIFT',
            action = act.Multiple({
                act.ClearScrollback('ScrollbackAndViewport'),
                act.SendKey({ key = 'l', mods = 'CTRL' }),
            }),
        },

        -- scroll up
        { key = 'e', mods = 'CTRL', action = act.ScrollByLine(-1) },
        { key = 'u', mods = 'CTRL', action = act.ScrollByPage(-0.5) },
        { key = 'b', mods = 'CTRL', action = act.ScrollByPage(-1) },

        -- scroll down
        { key = 'y', mods = 'CTRL', action = act.ScrollByLine(1) },
        { key = 'd', mods = 'CTRL', action = act.ScrollByPage(0.5) },
        { key = 'f', mods = 'CTRL', action = act.ScrollByPage(1) },

        -- osc 133 compatible commands
        -- see ~/.config/fish/conf.d/osc133.fish

        -- scroll up by command (osc 133)
        { key = 'k', mods = 'CTRL', action = act.ScrollToPrompt(-1) },
        -- scroll down by command (osc 133)
        { key = 'j', mods = 'CTRL', action = act.ScrollToPrompt(1) },

        -- enter search_mode (see key table below)
        { key = '/', action = act.Search('CurrentSelectionOrEmptyString') },

        -- entering search mode can also be done by searching for some of the
        -- frequent patterns below

        -- git commit hashes
        {
            key = 'g',
            mods = 'SHIFT|CTRL',
            action = act.Search({ Regex = '[a-f0-9]{6,}' }),
        },

        { key = 'Escape', action = act.PopKeyTable },
    },
    -- DON'T change the name of this key table, as wezterm looks for it
    search_mode = {
        -- change from case sensitive, to case insensitive, to regex
        { key = 'r', mods = 'CTRL', action = act.CopyMode('CycleMatchType') },

        -- clear search pattern
        { key = 'w', mods = 'CTRL', action = act.CopyMode('ClearPattern') },

        -- search upwards
        { key = 'Enter', action = act.CopyMode( 'PriorMatch') },
        { key = 'p', mods = 'CTRL', action = act.CopyMode('PriorMatch') },
        { key = 'UpArrow', action = act.CopyMode('PriorMatch') },

        -- search downwards
        { key = 'n', mods = 'CTRL', action = act.CopyMode('NextMatch') },
        { key = 'DownArrow', action = act.CopyMode('NextMatch') },

        { key = 'Escape', action = act.CopyMode('Close') },
    },
}

config.mouse_bindings = {
    {
        -- select whole output of command based on osc 133 sequences
        event = { Down = { streak = 4, button = 'Left' } },
        action = act.SelectTextAtMouseCursor('SemanticZone'),
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
