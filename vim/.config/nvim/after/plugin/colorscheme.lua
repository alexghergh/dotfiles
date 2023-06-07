-- everything colorscheme related goes in here
-- that includes setting up colors / highlights
-- see :h highlight
-- see :h colorscheme

-- most of the stuff here is set up to be the same as
-- ~/.config/tmux/colorscheme/tmux-colorscheme-chooser/colorschemes/space.sh in
-- order to be consistent

-- set colorscheme
if pcall(vim.cmd.colorscheme, 'melange') then

    -- better background color for floats and statusline
    vim.cmd('highlight NormalFloat guibg=#282c34')
    vim.cmd('highlight FloatBorder guifg=#867482 guibg=#282c34')
    vim.cmd('highlight StatusLine guibg=#282c34')

    -- set up statusline colors (matching tmux colorscheme)
    vim.cmd('highlight StatusLineColor1 guifg=#3d4451 guibg=#8ab977 gui=bold')
    vim.cmd('highlight StatusLineColor2 guifg=#a9a9af guibg=#3e4452 gui=bold')
    vim.cmd('highlight StatusLineColor3 guifg=#8ab977 guibg=#282c34')

    -- set up statusline diff stats (added, removed, modified)
    -- currently the background is hard-coded to color 2 above, since I couldn't
    -- find a way for the diffs to inherit the parent background
    vim.cmd('highlight StatusLineDiffAdd guifg=#78997a guibg=#3e4452 gui=bold')
    vim.cmd('highlight StatusLineDiffDelete guifg=#bd8183 guibg=#3e4452 gui=bold')
    vim.cmd('highlight StatusLineDiffChange guifg=#b380b0 guibg=#3e4452 gui=bold')
end
