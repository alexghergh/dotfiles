-- Plugins

local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

-- if packer is not installed, install it
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    packer_bootstrap = vim.fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.api.nvim_command("packadd packer.nvim")
end

local use = require("packer").use
require("packer").startup({function()

    -- Plugin manager can manage itself
    use "wbthomason/packer.nvim"

    -- Nvim-treesitter goodies
    use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
    use { "nvim-treesitter/playground", opt = true, cmd = { 'TSPlaygroundToggle' }, after = 'nvim-treesitter' }

    -- LSP
    use { "neovim/nvim-lspconfig" }

    -- TODO replace by nvim-cmp
    use { "hrsh7th/nvim-compe", config = function()
            -- config is done when an lsp server attached to a buffer
            -- see above 'custom_attach' function defined in 'nvim-lspconfig'
        end
    }

    -- LSP snippet support
    use { "L3MON4D3/LuaSnip", disable = true, config = function()
            vim.cmd [[
            imap <expr> <C-j> luasnip#expand_or_jumpable() ? '<Plug>luasnip-jump-next' : '<C-j>'
            imap <expr> <C-k> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<C-k>'

            snoremap <silent> <C-j> <Cmd>lua require('luasnip').jump(1)<Cr>
            snoremap <silent> <C-k> <Cmd>lua require('luasnip').jump(-1)<Cr>

            imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
            smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
            ]]

        end
    }

    -- Neovim-Tmux Navigation
    use { "alexghergh/nvim-tmux-navigation" }

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
    use { "tadaa/vimade" }

    -- Undotree
    use { "mbbill/undotree" }

    -- Easier lua keymappings
    use { "tjdevries/astronauta.nvim" }

    -- Colorschemes
    use { "savq/melange" }

    -- automatically set up the config after cloning packer.nvim on a fresh
    -- install
    -- note: this needs to be at the end of the plugins
    if packer_bootstrap then
        require("packer").sync()
    end

end, config = {
    display = {
        open_fn = function()
            return require("packer.util").float({ border = "rounded" })
        end,
    }
}})

vim.cmd [[autocmd ColorScheme * highlight NormalFloat guibg=#1f2335]]
vim.cmd [[autocmd ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]]


-- vim: set tw=0 fo-=r
