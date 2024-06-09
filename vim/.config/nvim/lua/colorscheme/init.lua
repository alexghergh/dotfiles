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
-- see: ~/.config/tmux/colorscheme/tmux-colorscheme-chooser/colorschemes/*
-- see :h highlight
-- see :h colorscheme
--

-- run on :colorscheme (re)load
vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
        local status, result =
            pcall(require, 'colorscheme.' .. vim.g.colors_name)
        if status then
            result.setup()
        end
    end,
    group = vim.api.nvim_create_augroup('_user_group', { clear = false }),
})

-- vim: set tw=0 fo-=r ft=lua
