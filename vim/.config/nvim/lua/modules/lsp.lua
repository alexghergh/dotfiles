--
-- lsp servers setup
--
-- includes setting up lsp configs, the auto-completion engine managed by
-- nvim-cmp, and any other off-spec lsp servers
--
-- see :h vim.lsp
--

-- lsp servers (see specific opts below)
local servers = {
    'basedpyright',
    'ruff',
    'jdtls',
    'lua_ls',
    'marksman',
    'yamlls',
    'texlab',
    'clangd',
    'gopls',
    'rust_analyzer',
}

return {

    -- lsp servers package manager
    --
    -- see :h mason.nvim
    {
        'mason-org/mason.nvim',
        opts = {
            -- registries for config download
            registries = {
                'github:alexghergh/mason-registry', -- clangd arm64 support
                'github:mason-org/mason-registry',
            },
        },
    },

    -- literally here just to make sure that servers are auto-installed on new config
    {
        'mason-org/mason-lspconfig.nvim',
        opts = {
            ensure_installed = servers,
        },
    },

    -- off-spec LSP server stuff
    {
        'p00f/clangd_extensions.nvim',
    },

    -- neovim dev off-spec lsp to assist with lua configs; sets up runtime deps
    -- for neovim
    --
    -- see :h lazydev
    {
        'folke/lazydev.nvim',
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
            'folke/lazydev.nvim',
        },
        opts = {},
        config = function(_, _)
            -- global opts
            vim.lsp.config('*', {
                capabilities = require('cmp_nvim_lsp').default_capabilities(),
                -- init_options = {
                --     usePlaceholders = true, -- snippet expansion for func args
                -- },
            })

            -- specific opts
            vim.lsp.config('basedpyright', {
                settings = {
                    basedpyright = {
                        analysis = {
                            autoSearchPaths = true,
                            typeCheckingMode = 'standard',
                        },
                    },
                },
            })

            -- custom LspAttach / LspDetach functionality for the built-in
            -- neovim lsp client
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    -- options for the nvim lsp keymaps
                    local buf = args.buf
                    local win = vim.api.nvim_get_current_win()
                    local Client = vim.lsp.get_client_by_id(args.data.client_id)
                    local vlb = vim.lsp.buf

                    if Client == nil then
                        return
                    end

                    -- buffer mappings for LSP servers

                    -- gD and gd below override the builtins, which makes
                    -- mappings consistent whether there is an LSP server or not

                    -- goto * (see also lua/modules/telescope.lua)
                    vim.keymap.set('n', 'gD', vlb.declaration, { buffer = buf, desc = 'Go to declaration' })
                    vim.keymap.set('n', 'gd', vlb.definition, { buffer = buf, desc = 'Go to definition' })
                    vim.keymap.set('n', '<Leader>gi', vlb.implementation, { buffer = buf, desc = 'Go to implementation' })
                    vim.keymap.set('n', '<Leader>gr', vlb.references, { buffer = buf, desc = 'Go to references' })
                    vim.keymap.set('n', '<Leader>td', vlb.type_definition, { buffer = buf, desc = 'Go to type definition' })
                    vim.keymap.set('n', '<Leader>th', vlb.typehierarchy, { buffer = buf, desc = 'Go to type hierarchy' })

                    -- signature help / hover
                    vim.keymap.set('n', 'K', vlb.hover, { buffer = buf, desc = 'Symbol hover information' })
                    vim.keymap.set('n', '<C-k>', vlb.signature_help, { buffer = buf, desc = 'Display signature help' })
                    vim.keymap.set('i', '<C-/>', vlb.signature_help, { buffer = buf, desc = 'Display signature help' })

                    -- TODO document_symbol + on_list to filter e.g. only functions
                    -- that should be easier to navigate properly in the file

                    -- symbol rename
                    vim.keymap.set('n', '<Leader>rn', vlb.rename, { buffer = buf, desc = 'Rename symbol under cursor' })

                    -- formatting
                    vim.keymap.set({ 'n', 'v' }, '<Leader>f', function()
                        vlb.format({ async = true })
                    end, { buffer = buf, desc = 'Format text' })
                    -- code actions
                    vim.keymap.set({ 'n', 'v' }, '<Leader>ca', vlb.code_action, { buffer = buf, desc = 'Display code actions' })

                    -- omnifunc / tagfunc completion
                    if Client:supports_method('completionItem/resolve') then
                        vim.bo[args.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
                    end
                    if Client:supports_method('textDocument/definition') then
                        vim.bo[args.buf].tagfunc = 'v:lua.vim.lsp.tagfunc'
                    end

                    -- symbol highlighting on hover
                    if Client:supports_method('textDocument/documentHighlight') then
                        vim.api.nvim_create_augroup('lsp_doc_highlight', { clear = false })
                        vim.api.nvim_clear_autocmds({
                            buffer = args.buf,
                            group = 'lsp_doc_highlight',
                        })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = args.buf,
                            group = 'lsp_doc_highlight',
                            callback = vlb.document_highlight,
                        })
                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = args.buf,
                            group = 'lsp_doc_highlight',
                            callback = vlb.clear_references,
                        })
                    end

                    -- folding (overrides treesitter's folding method)
                    if Client:supports_method('textDocument/foldingRange') then
                        vim.wo[win][0].foldmethod = 'expr'
                        vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
                    end
                end,
                group = vim.api.nvim_create_augroup('_user_group', { clear = false }),
            })

            vim.api.nvim_create_autocmd('LspDetach', {
                callback = function(_)
                    -- reset omnifunc, tagfunc, foldexpr
                    vim.cmd('setlocal tagfunc< omnifunc< foldexpr<')
                end,
            })

            -- enable the lsp servers
            for _, lsp in ipairs(servers) do
                vim.lsp.enable(lsp)
            end
        end,
    },
}
