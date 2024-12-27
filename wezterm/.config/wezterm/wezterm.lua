local wezterm = require('wezterm')
local act = wezterm.action
local background = require('background')
local smart_splits = require('smart-splits')

local config = wezterm.config_builder()

config.color_scheme = 'Afterglow'

config.font = wezterm.font_with_fallback({
    'Cascadia Code',
    'SF Mono',
    'Source Code Pro',
    'JetBrains Mono',
    'Fira Code',
    'Hack',
}, { weight = 'DemiLight' })
config.font_size = 13
config.adjust_window_size_when_changing_font_size = false
config.initial_rows = 37
config.initial_cols = 150

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
    selection_bg = '#ffe0b2',

    -- change cursor color on leader key, dead key or IME 'compose' state
    compose_cursor = 'orange',

    -- quick selection
    quick_select_label_bg = { Color = 'orange' },
    quick_select_label_fg = { Color = 'black' },
    quick_select_match_bg = { AnsiColor = 'Maroon' },
    quick_select_match_fg = { Color = '#ffffff' },
}

-- choose random background seeded by day of the year
local now = os.date('*t', os.time())
math.randomseed(tonumber(now.yday))
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
-- config.term = 'wezterm' -- ncurses fucked this up (again), keep commented for now

config.scrollback_lines = 10000

-- quick selection key press alphabet (prefer right hand first, due to left
-- shift pinky press on copy/paste)
config.quick_select_alphabet = 'htnsgcrlmwvzfdbaoeuqjkxpyi'

-- configs for hyperlink rules (make things clickable in wezterm)
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- github links of the form "user/project"
table.insert(config.hyperlink_rules, {
    regex = '[" ]{1}([\\w\\d]{1}[-\\w\\d]+)(/){1}([-\\w\\d\\.]+)[" ]{1}',
    format = 'https://www.github.com/$1/$3',
})

config.launch_menu = {
    {
        args = { 'htop' },
    },
    {
        label = 'neovim - init',
        args = { 'nvim', 'init.lua' },
        cwd = '/home/alex/.config/nvim/',
    },
    {
        label = 'neovim - keymaps',
        args = { 'nvim', 'keymaps.lua' },
        cwd = '/home/alex/.config/nvim/lua/core',
    },
    {
        label = 'neovim - plugins',
        args = { 'nvim', 'modules' },
        cwd = '/home/alex/.config/nvim/lua/',
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
        label = 'fish - functions/',
        args = { 'nvim', 'functions/' },
        cwd = '/home/alex/.config/fish/',
    },
    {
        label = 'fish - abbr.fish',
        args = { 'nvim', 'conf.d/abbr.fish' },
        cwd = '/home/alex/.config/fish/',
    },
    {
        label = 'Notes / TODOs',
        args = { 'nvim', 'TODO.md' },
        cwd = '/home/alex/projects/dotfiles/',
    },
}

wezterm.on('update-right-status', function(window, _)
    -- "Sun April 22 22:50"
    local date = wezterm.strftime('%a %b %-d %H:%M')

    local bat = ''
    for _, b in ipairs(wezterm.battery_info()) do
        local bat_status = ''
        if b.state == 'Charging' then
            bat_status = 'Ch.'
        elseif b.state == 'Discharging' then
            bat_status = 'Disch.'
        end

        bat = string.format('%s %.0f%%', bat_status, b.state_of_charge * 100)
    end

    -- display active key table
    local key_tbl = window:active_key_table()
    if key_tbl then
        key_tbl = 'KEY TABLE: ' .. key_tbl
    else
        key_tbl = ''
    end

    local sep = wezterm.nerdfonts.ple_left_half_circle_thin
    window:set_right_status(wezterm.format({
        { Text = key_tbl },
        'ResetAttributes',
        { Foreground = { AnsiColor = 'Yellow' } },
        {
            Text = ' ' .. sep .. ' ' .. bat .. ' ' .. sep .. ' ' .. date .. ' ',
        },
    }))
end)

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

    -- switch pane (wezterm or neovim, see smart-splits.nvim)
    smart_splits.move_cursor('h', 'Left'),
    smart_splits.move_cursor('l', 'Right'),
    smart_splits.move_cursor('j', 'Down'),
    smart_splits.move_cursor('k', 'Up'),

    -- switch tab
    { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
    { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
    { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
    { key = '4', mods = 'LEADER', action = act.ActivateTab(3) },
    { key = '5', mods = 'LEADER', action = act.ActivateTab(4) },
    { key = '6', mods = 'LEADER', action = act.ActivateTab(5) },
    { key = '7', mods = 'LEADER', action = act.ActivateTab(6) },
    { key = '8', mods = 'LEADER', action = act.ActivateTab(8) },
    { key = '9', mods = 'LEADER', action = act.ActivateTab(-1) },

    -- copy
    { key = 'c', mods = 'SUPER', action = act.CopyTo('Clipboard') },
    { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },

    -- paste
    { key = 'v', mods = 'SUPER', action = act.PasteFrom('Clipboard') },
    { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom('Clipboard') },

    -- fullscreen
    { key = 'z', mods = 'LEADER', action = act.ToggleFullScreen },

    -- show launcher
    { key = 'l', mods = 'LEADER', action = act.ShowLauncher },

    -- show command palette
    { key = 'h', mods = 'LEADER', action = act.ActivateCommandPalette },

    -- show debug overlay
    { key = 'd', mods = 'LEADER', action = act.ShowDebugOverlay },

    -- show unicode char select
    { key = 'u', mods = 'LEADER', action = act.CharSelect },

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
            timeout_milliseconds = 1000,
        }),
    },

    -- resize pane (wezterm or neovim, see smart-splits.nvim)
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

    -- copy mode
    {
        key = 'c',
        mods = 'LEADER',
        action = act.ActivateCopyMode,
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

    -- quick select
    {
        key = 'q',
        mods = 'LEADER',
        action = act.QuickSelect,
    },
}

config.key_tables = {
    pane_key_table = {
        -- select pane by label
        { key = 'p', action = act.PaneSelect({ mode = 'Activate' }) },

        -- swap pane with active
        {
            key = 's',
            action = act.PaneSelect({ mode = 'SwapWithActiveKeepFocus' }),
        },

        -- break pane to new tab / window
        { key = 'b', action = act.PaneSelect({ mode = 'MoveToNewTab' }) },
        { key = 'w', action = act.PaneSelect({ mode = 'MoveToNewWindow' }) },

        -- rotate panes
        { key = 'r', action = act.RotatePanes('Clockwise') },

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

        -- move tab
        { key = '1', mods = 'ALT', action = act.MoveTab(0) },
        { key = '2', mods = 'ALT', action = act.MoveTab(1) },
        { key = '3', mods = 'ALT', action = act.MoveTab(2) },
        { key = '4', mods = 'ALT', action = act.MoveTab(3) },
        { key = '5', mods = 'ALT', action = act.MoveTab(4) },
        { key = '6', mods = 'ALT', action = act.MoveTab(5) },
        { key = '7', mods = 'ALT', action = act.MoveTab(6) },
        { key = '8', mods = 'ALT', action = act.MoveTab(7) },
        { key = '9', mods = 'ALT', action = act.MoveTab(8) },

        { key = 'h', mods = 'ALT', action = act.MoveTabRelative(-1) },
        { key = 'l', mods = 'ALT', action = act.MoveTabRelative(1) },

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
        { key = 'n', action = act.Multiple({ act.SpawnWindow }) },

        { key = 'Escape', action = act.PopKeyTable },
    },
    resize_pane = {
        smart_splits.resize_pane('LeftArrow', 'Left'),
        smart_splits.resize_pane('h', 'Left'),

        smart_splits.resize_pane('RightArrow', 'Right'),
        smart_splits.resize_pane('l', 'Right'),

        smart_splits.resize_pane('DownArrow', 'Down'),
        smart_splits.resize_pane('j', 'Down'),

        smart_splits.resize_pane('UpArrow', 'Up'),
        smart_splits.resize_pane('k', 'Up'),

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

        -- path-like objects (needs to have / inside, whitespace around)
        --
        -- the regex below tries to match a path in 3 parts:
        -- beginning: match /, ~/, ./, ../, or "directory/"
        -- middle: match as many "directory/", ".directory/" or "../" as possible
        -- end: match "directory", ".directory" or "file.extension"
        {
            key = 'p',
            mods = 'SHIFT|CTRL',
            action = act.Search({
                Regex = '[ ]((?:(?:\\.){1,2}|~|\\w+)?/(?:(?:\\.?\\w+|(?:\\.){1,2})/)*(?:(?:\\w+)\\.(?:\\w+)|(?:\\.)?\\w+|))[ ]',
            }),
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
        { key = 'Enter', action = act.CopyMode('PriorMatch') },
        { key = 'p', mods = 'CTRL', action = act.CopyMode('PriorMatch') },
        { key = 'UpArrow', action = act.CopyMode('PriorMatch') },

        -- search downwards
        { key = 'n', mods = 'CTRL', action = act.CopyMode('NextMatch') },
        { key = 'DownArrow', action = act.CopyMode('NextMatch') },

        { key = 'Escape', action = act.CopyMode('Close') },
    },
}

-- Use SHIFT to bypass application mouse reporting (note that binding anything
-- with SHIFT as mod won't work inside apps like nvim, when this option is set)
config.bypass_mouse_reporting_modifiers = 'SHIFT'
config.disable_default_mouse_bindings = true
config.mouse_bindings = {
    --
    -- text selection
    --

    -- cell selection
    {
        event = { Down = { streak = 1, button = 'Left' } },
        action = act.SelectTextAtMouseCursor('Cell'),
    },

    -- word selection
    {
        event = { Down = { streak = 2, button = 'Left' } },
        action = act.SelectTextAtMouseCursor('Word'),
    },

    -- line selection
    {
        event = { Down = { streak = 3, button = 'Left' } },
        action = act.SelectTextAtMouseCursor('Line'),
    },

    -- select whole output of command based on osc 133 sequences
    {
        event = { Down = { streak = 4, button = 'Left' } },
        action = act.SelectTextAtMouseCursor('SemanticZone'),
    },

    -- extend selection by cell
    {
        event = { Drag = { streak = 1, button = 'Left' } },
        action = act.ExtendSelectionToMouseCursor('Cell'),
    },

    -- extend selection by word
    {
        event = { Drag = { streak = 2, button = 'Left' } },
        action = act.ExtendSelectionToMouseCursor('Word'),
    },

    -- extend selection by line
    {
        event = { Drag = { streak = 3, button = 'Left' } },
        action = act.ExtendSelectionToMouseCursor('Line'),
    },

    -- extend selection by block (can be triggered from cell, word or line)
    {
        event = { Drag = { streak = 1, button = 'Left' } },
        mods = 'SHIFT',
        action = act.ExtendSelectionToMouseCursor('Block'),
    },
    {
        event = { Drag = { streak = 2, button = 'Left' } },
        mods = 'SHIFT',
        action = act.ExtendSelectionToMouseCursor('Block'),
    },
    {
        event = { Drag = { streak = 3, button = 'Left' } },
        mods = 'SHIFT',
        action = act.ExtendSelectionToMouseCursor('Block'),
    },

    -- copy to primary selection
    {
        event = { Up = { streak = 1, button = 'Left' } },
        action = act.CompleteSelection('PrimarySelection'),
    },
    {
        event = { Up = { streak = 2, button = 'Left' } },
        action = act.CompleteSelection('PrimarySelection'),
    },
    {
        event = { Up = { streak = 3, button = 'Left' } },
        action = act.CompleteSelection('PrimarySelection'),
    },
    {
        event = { Up = { streak = 4, button = 'Left' } },
        action = act.CompleteSelection('PrimarySelection'),
    },

    --
    -- misc
    --

    -- scroll by mouse wheel
    {
        event = { Down = { streak = 1, button = { WheelUp = 1 } } },
        action = act.ScrollByLine(-3),
    },
    {
        event = { Down = { streak = 1, button = { WheelDown = 1 } } },
        action = act.ScrollByLine(3),
    },

    -- open hyperlinks (disable mouse down to avoid unintuitive behaviour)
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'CTRL',
        action = act.OpenLinkAtMouseCursor,
    },
    {
        event = { Down = { streak = 1, button = 'Left' } },
        mods = 'CTRL',
        action = act.Nop,
    },

    -- paste from selection
    {
        event = { Down = { streak = 1, button = 'Middle' } },
        action = act.PasteFrom('PrimarySelection'),
    },
    {
        event = { Down = { streak = 1, button = 'Right' } },
        mods = 'CTRL',
        action = act.PasteFrom('PrimarySelection'),
    },

    -- on text selected, copy to clipboard, otherwise paste
    {
        event = { Down = { streak = 1, button = 'Right' } },
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ''
            if has_selection then
                window:perform_action(act.CopyTo('Clipboard'), pane)
                window:perform_action(act.ClearSelection, pane)
            else
                window:perform_action(act.PasteFrom('Clipboard'), pane)
            end
        end),
    },
}

return config
