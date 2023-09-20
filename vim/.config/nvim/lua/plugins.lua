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
        -- same as :TSUpdate(), but doesn't break on first time use
        -- works fine for lazy.nvim
        run = function()
            local ts_update = require('nvim-treesitter.install').update({
                with_sync = true
            })
            ts_update()
        end,
    }

    use { 'nvim-treesitter/playground',
        opt = true,
        cmd = {
            'TSPlaygroundToggle',
            'TSHighlightCapturesUnderCursor',
            'TSNodeUnderCursor',
        }
    }

    -- LSP configs
    use { 'folke/neodev.nvim' }
    use { 'neovim/nvim-lspconfig' }
    use { 'hrsh7th/cmp-nvim-lsp' }
    use { 'hrsh7th/cmp-buffer' }
    use { 'hrsh7th/nvim-cmp' }

    -- neovim-tmux navigation
    use { 'alexghergh/nvim-tmux-navigation' }

    -- commentary
    use { 'tpope/vim-commentary' }

    -- surroundings
    use { 'tpope/vim-surround' }

    -- git integration
    use { 'mhinz/vim-signify' }

    -- modelines
    use { 'alexghergh/securemodelines' }

    -- undotree
    use { 'mbbill/undotree' }

    -- colorschemes
    use { 'savq/melange-nvim' }

    -- indentlines
    use { 'lukas-reineke/indent-blankline.nvim' }

    -- visual search
    use { 'bronson/vim-visual-star-search' }

    -- automatically set up the config after cloning
    if packer_installed == false then
        require('packer').sync()
    end
end,
config = {
    display = {
        open_fn = function()
            -- open packer window with enough space for the commit diff at the bottom
            local win_height = vim.fn.winheight(0)
            local win_width = vim.fn.winwidth(0)

            return require('packer.util').float({
                    border = 'single',
                    width = math.floor(0.8 * win_width),
                    height = math.floor(0.6 * win_height),
                    col = math.floor(0.1 * win_width),
                    row = math.floor(0.1 * win_height),
                })
        end
    },
    profile = {
        -- to profile set this to 'true' and run :PackerProfile
        enable = false,

        -- the amount in ms that a plugin's load time must be over for
        -- it to be included in the profile
        threshold = 0,
    }
}})

-- vim: set tw=0 fo-=r ft=lua
