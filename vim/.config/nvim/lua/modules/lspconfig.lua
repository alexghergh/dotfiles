--
-- lsp servers setup
--
-- this includes setting up the lsp configs, as well as the auto-completion
-- engine managed by nvim-cmp, and any other off-spec lsp servers
--
-- see :h vim.lsp
-- see lua/core/lsp_client.lua
--

-- handlers overrides
local handlers = {
    -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization, 1st tip
    ['textDocument/hover'] = vim.lsp.with(
        vim.lsp.handlers.hover,
        { border = 'rounded' }
    ),
    ['textDocument/signatureHelp'] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        { border = 'rounded' }
    ),
}

-- lsp servers
local servers = {
    -- pacman ccls
    'ccls',

    -- pacman pyright
    'pyright',

    -- see ~/packages folder
    'jdtls',

    -- pacman lua-language-server
    'lua_ls',
}

return {

    -- neovim development lsp setup
    -- off spec lsp to assist in lua neovim configs
    -- sets up runtime dependencies for neovim stuff
    --
    -- see :h neodev
    {
        -- TODO replace with lazydev.nvim
        'folke/neodev.nvim',
        opts = {},
        dependencies = {
            'hrsh7th/nvim-cmp',
        },
    },

    -- neovim lsp server configs
    --
    -- see :h vim.lsp
    -- see :h lspconfig
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'hrsh7th/nvim-cmp',
            'hrsh7th/cmp-nvim-lsp',
            'folke/neodev.nvim',
        },
        opts = {},
        config = function(_, _)
            -- border for :LspInfo
            require('lspconfig.ui.windows').default_options.border = 'rounded'

            -- custom LspAttach / LspDetach functionality for the built-in
            -- neovim lsp client
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    -- options for the nvim lsp keymaps
                    local opts = { buffer = args.buf }
                    local client = vim.lsp.get_client_by_id(args.data.client_id)

                    -- buffer mappings for LSP servers

                    -- most of the below override the builtins, which is exactly
                    -- what we want, i.e. have the same mappings whether there
                    -- is an LSP-server present or not

                    -- goto *
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', '<Leader>gi', vim.lsp.buf.implementation, opts)
                    vim.keymap.set('n', '<Leader>gr', vim.lsp.buf.references, opts)
                    vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, opts) -- <L>gt

                    -- signature help / hover
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

                    -- symbol rename
                    vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)

                    -- formatting
                    vim.keymap.set('n', '<Leader>f', function()
                        vim.lsp.buf.format({ async = true })
                    end, opts)

                    -- code actions
                    vim.keymap.set(
                        { 'n', 'v' },
                        '<Leader>ca',
                        vim.lsp.buf.code_action,
                        opts
                    )

                    -- omnifunc / tagfunc completion
                    if client.server_capabilities.completionProvider then
                        vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
                    end
                    if client.server_capabilities.definitionProvider then
                        vim.bo[args.buf].tagfunc = "v:lua.vim.lsp.tagfunc"
                    end

                    -- symbol highlighting on hover
                    if client.server_capabilities.documentHighlightProvider then
                        vim.api.nvim_create_augroup('lsp_doc_highlight', { clear = false })
                        vim.api.nvim_clear_autocmds({
                            buffer = args.buf,
                            group = 'lsp_doc_highlight',
                        })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = args.buf,
                            group = 'lsp_doc_highlight',
                            callback = vim.lsp.buf.document_highlight,
                        })
                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = args.buf,
                            group = 'lsp_doc_highlight',
                            callback = vim.lsp.buf.clear_references,
                        })
                    end
                end,
                group = vim.api.nvim_create_augroup('_user_group', { clear = false }),
            })

            vim.api.nvim_create_autocmd("LspDetach", {
                callback = function(_)
                    -- reset omnifunc, tagfunc
                    vim.cmd("setlocal tagfunc< omnifunc<")
                end,
            })

            -- setup the lsp servers
            for _, lsp in ipairs(servers) do
                require('lspconfig')[lsp].setup({
                    capabilities = require('cmp_nvim_lsp').default_capabilities(),
                    handlers = handlers,
                })
            end
        end,
    },
}

-- vim: set tw=0 fo-=r ft=lua
