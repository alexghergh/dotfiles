--
-- everything colorscheme related goes in here;
-- that includes setting up colors / highlights
--
-- the actual colorscheme is set in init.lua
--
-- most of the stuff here is set up to be the same as
-- ~/.config/tmux/colorscheme/tmux-colorscheme-chooser/colorschemes/* in
-- order to be consistent
--
-- see :h highlight
-- see :h colorscheme
-- see API in lua/statusline.lua
--

if vim.g.colors_name == 'melange' then

    -- better background color for floats and statusline
    vim.cmd('highlight NormalFloat guibg=#282c34')
    vim.cmd('highlight FloatBorder guifg=#867482 guibg=#282c34')
    vim.cmd('highlight StatusLine guibg=#282c34')

    -- set up statusline colors (matching tmux colorscheme)
    vim.cmd('highlight StatusLineColor1 guifg=#a9a9af guibg=#3e4452')
    vim.cmd('highlight StatusLineColor2 guifg=#8ab977 guibg=#282c34')

    -- set up statusline diff stats (added, removed, modified)
    -- the background is hard-coded to color 2 above
    vim.cmd('highlight StatusLineDiffAdd guifg=#78997a guibg=#282c34')
    vim.cmd('highlight StatusLineDiffDelete guifg=#bd8183 guibg=#282c34')
    vim.cmd('highlight StatusLineDiffChange guifg=#b380b0 guibg=#282c34')
end
