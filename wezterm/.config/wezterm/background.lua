-- background configs for different assets
local path = os.getenv('HOME')
    .. '/projects/dotfiles/wezterm/.config/wezterm/assets/'

-- double nesting allows for backgrounds containing multiple images
local background = {
    {
        {
            source = {
                File = path .. 'game_background_1/game_background_1.png',
            },
            hsb = { brightness = 0.05 },
        },
    },
    {
        {
            source = {
                File = path .. 'game_background_2/game_background_2.png',
            },
            hsb = { brightness = 0.05 },
        },
    },
    {
        {
            source = {
                File = path .. 'game_background_3/game_background_3.png',
            },
            hsb = { brightness = 0.4 },
        },
    },
    {
        {
            source = {
                File = path .. 'game_background_4/game_background_4.png',
            },
            hsb = { brightness = 0.1 },
        },
    },
    {
        {
            source = {
                File = path .. 'springstar_fields.png',
            },
            hsb = { brightness = 0.07 },
        },
    },
    {
        {
            source = {
                File = path .. 'windrise-background-4k.png',
            },
            hsb = { brightness = 0.1 },
        },
    },
    {
        {
            source = {
                File = path .. 'Clouds 1/1.png',
            },
            hsb = { brightness = 0.05 },
        },
        {
            source = {
                File = path .. 'Clouds 1/2.png',
            },
            hsb = { brightness = 0.05 },
        },
        {
            source = {
                File = path .. 'Clouds 1/4.png',
            },
            hsb = { brightness = 0.05 },
        },
    },
    {
        {
            source = {
                File = path .. 'Clouds 2/1.png',
            },
            hsb = { brightness = 0.05 },
        },
        {
            source = {
                File = path .. 'Clouds 2/2.png',
            },
            hsb = { brightness = 0.05 },
        },
        {
            source = {
                File = path .. 'Clouds 2/3.png',
            },
            hsb = { brightness = 0.05 },
        },
        {
            source = {
                File = path .. 'Clouds 2/4.png',
            },
            hsb = { brightness = 0.05 },
        },
    },
    {
        {
            source = {
                File = path .. 'Clouds 3/1.png',
            },
            hsb = { brightness = 0.5 },
        },
        {
            source = {
                File = path .. 'Clouds 3/3.png',
            },
            hsb = { brightness = 0.5 },
        },
        {
            source = {
                File = path .. 'Clouds 3/4.png',
            },
            hsb = { brightness = 0.5 },
        },
    },
    {
        {
            source = {
                File = path .. 'Clouds 4/1.png',
            },
            hsb = { brightness = 0.1 },
        },
        {
            source = {
                File = path .. 'Clouds 4/3.png',
            },
            hsb = { brightness = 0.1 },
        },
        {
            source = {
                File = path .. 'Clouds 4/4.png',
            },
            hsb = { brightness = 0.1 },
        },
    },
    {
        {
            source = {
                File = path .. 'Clouds 5/1.png',
            },
            hsb = { brightness = 0.1 },
        },
        {
            source = {
                File = path .. 'Clouds 5/3.png',
            },
            hsb = { brightness = 0.1 },
        },
        {
            source = {
                File = path .. 'Clouds 5/4.png',
            },
            hsb = { brightness = 0.1 },
        },
        {
            source = {
                File = path .. 'Clouds 5/5.png',
            },
            hsb = { brightness = 0.1 },
        },
    },
    {
        {
            source = {
                File = path .. 'Clouds 6/1.png',
            },
            hsb = { brightness = 0.1 },
        },
        {
            source = {
                File = path .. 'Clouds 6/2.png',
            },
            hsb = { brightness = 0.1 },
        },
        {
            source = {
                File = path .. 'Clouds 6/3.png',
            },
            hsb = { brightness = 0.1 },
        },
        {
            source = {
                File = path .. 'Clouds 6/4.png',
            },
            hsb = { brightness = 0.05 },
        },
        {
            source = {
                File = path .. 'Clouds 6/5.png',
            },
            hsb = { brightness = 0.05 },
        },
        {
            source = {
                File = path .. 'Clouds 6/6.png',
            },
            hsb = { brightness = 0.05 },
        },
    },
    {
        {
            source = {
                File = path .. 'Clouds 7/1.png',
            },
            hsb = { brightness = 0.1 },
        },
        {
            source = {
                File = path .. 'Clouds 7/2.png',
            },
            hsb = { brightness = 0.05 },
        },
        {
            source = {
                File = path .. 'Clouds 7/3.png',
            },
            hsb = { brightness = 0.1 },
        },
        {
            source = {
                File = path .. 'Clouds 7/4.png',
            },
            hsb = { brightness = 0.1 },
        },
    },
    {
        {
            source = {
                File = path .. 'Clouds 8/1.png',
            },
            hsb = { brightness = 0.1 },
        },
        {
            source = {
                File = path .. 'Clouds 8/2.png',
            },
            hsb = { brightness = 0.05 },
        },
        {
            source = {
                File = path .. 'Clouds 8/3.png',
            },
            hsb = { brightness = 0.05 },
        },
        {
            source = {
                File = path .. 'Clouds 8/4.png',
            },
            hsb = { brightness = 0.05 },
        },
        {
            source = {
                File = path .. 'Clouds 8/5.png',
            },
            hsb = { brightness = 0.05 },
        },
        {
            source = {
                File = path .. 'Clouds 8/6.png',
            },
            hsb = { brightness = 0.05 },
        },
    },
    {
        {
            source = {
                File = path .. 'Ocean_1/4.png',
            },
            hsb = { brightness = 0.15 },
        },
    },
    {
        {
            source = {
                File = path .. 'Ocean_2/5.png',
            },
            hsb = { brightness = 0.15 },
        },
    },
    {
        {
            source = {
                File = path .. 'Ocean_3/5.png',
            },
            hsb = { brightness = 0.1 },
        },
    },
    {
        {
            source = {
                File = path .. 'Ocean_4/5.png',
            },
            hsb = { brightness = 0.05 },
        },
    },
    {
        {
            source = {
                File = path .. 'Ocean_5/5.png',
            },
            hsb = { brightness = 0.15 },
        },
    },
    {
        {
            source = {
                File = path .. 'Ocean_6/1.png',
            },
            hsb = { brightness = 0.3 },
        },
        {
            source = {
                File = path .. 'Ocean_6/3.png',
            },
            hsb = { brightness = 0.3 },
        },
        {
            source = {
                File = path .. 'Ocean_6/4.png',
            },
            hsb = { brightness = 0.3 },
        },
    },
    {
        {
            source = {
                File = path .. 'Ocean_7/6.png',
            },
            hsb = { brightness = 0.05 },
        },
    },
    {
        {
            source = {
                File = path .. 'Ocean_8/6.png',
            },
            hsb = { brightness = 0.15 },
        },
    },
}

return background
