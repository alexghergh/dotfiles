-- error checking
if not pcall(require, "nvim-tmux-navigation") then
    return
end

require'nvim-tmux-navigation'.setup {
    disable_when_zoomed = true,
    keybindings = {
        left = "<M-h>",
        down = "<M-j>",
        up = "<M-k>",
        right = "<M-l>",
        last_active = "<Leader>lp",
    }
}
