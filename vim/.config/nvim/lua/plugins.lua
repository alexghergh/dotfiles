--
-- plugins
--

-- if packer is not installed, install it
local is_packer_installed = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1',
            'https://github.com/wbthomason/packer.nvim',
            install_path })
        vim.cmd [[ packadd packer.nvim ]]
        return false
    end
    return true
end

local packer_installed = is_packer_installed()

require('packer').startup({function(use)

     -- plugin manager can manage itself
     use { 'wbthomason/packer.nvim' }

     -- nvim-treesitter goodies
     use { 'nvim-treesitter/nvim-treesitter',
         run = ':TSUpdate' -- post-install/update
     }

     use { 'nvim-treesitter/playground',
         -- opt = true,
         -- cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" }
     }

    -- LSP
    -- use { "neovim/nvim-lspconfig" }

    -- -- TODO replace by nvim-cmp
    -- use { "hrsh7th/nvim-compe", config = function()
    --         -- config is done when an lsp server attached to a buffer
    --         -- see above 'custom_attach' function defined in 'nvim-lspconfig'
    --     end
    -- }

    -- -- LSP snippet support
    -- use { "L3MON4D3/LuaSnip", disable = true, config = function()
    --         vim.cmd [[
    --         imap <expr> <C-j> luasnip#expand_or_jumpable() ? '<Plug>luasnip-jump-next' : '<C-j>'
    --         imap <expr> <C-k> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<C-k>'

    --         snoremap <silent> <C-j> <Cmd>lua require('luasnip').jump(1)<Cr>
    --         snoremap <silent> <C-k> <Cmd>lua require('luasnip').jump(-1)<Cr>

    --         imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
    --         smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
    --         ]]

    --     end
    -- }

    -- Neovim-Tmux Navigation
    use { "alexghergh/nvim-tmux-navigation" }
    -- use { "~/projects/nvim-tmux-navigation/" }

    -- Visual selection search
    use { "bronson/vim-visual-star-search" }

    -- Commentary
    use { "tpope/vim-commentary" }

    -- Surroundings
    use { "tpope/vim-surround" }

    -- Git integration
    use { "mhinz/vim-signify" }

    -- Modelines
    use { "alexghergh/securemodelines" }

    -- Fade inactive window
    use { "tadaa/vimade", disable = true }

    -- Undotree
    use { "mbbill/undotree" }

    -- Colorschemes
    use { "savq/melange" }

    -- Formatting
    use { "editorconfig/editorconfig-vim" }

    -- automatically set up the config after cloning
    if packer_installed == false then
        require('packer').sync()
    end
end,
config = {
    display = {
        open_fn = function()
            return require('packer.util').float({ border = 'single' })
        end
    },
    profile = {
        enable = false, -- to profile set this to 'true' and run :PackerProfile
        -- the amount in ms that a plugin's load time must be over for
        -- it to be included in the profile
        threshold = 0,
    }
}})

-- vim: set tw=0 fo-=r ft=lua
