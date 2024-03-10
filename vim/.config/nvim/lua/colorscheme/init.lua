--
-- everything colorscheme related goes in here;
-- that includes setting up colors / highlights
--
-- the actual colorscheme is set in init.lua
--
-- most of the stuff here is set up to be consistent with tmux, or because the
-- colorscheme doesn't support all the highlighting groups of some of the
-- plugins
--
--
-- see: ~/.config/tmux/colorscheme/tmux-colorscheme-chooser/colorschemes/*
-- see :h highlight
-- see :h colorscheme
--

-- run on :colorscheme (re)load
vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
        if vim.g.colors_name == 'melange' then
            require('colorscheme.melange').setup()
        end
    end,
    group = vim.api.nvim_create_augroup('_user_group', { clear = false }),
})
