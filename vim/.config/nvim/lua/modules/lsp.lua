--
-- lsp servers setup
--
-- includes setting up lsp configs, the auto-completion engine managed by
-- nvim-cmp, and any other off-spec lsp servers
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
    {
        'basedpyright',
        settings = {
            basedpyright = {
                analysis = {
                    autoSearchPaths = true,
                    typeCheckingMode = 'standard',
                },
            },
        },
    },
    'ruff',
    'jdtls',
    'lua_ls',
    { 'harper_ls', filetypes = { 'markdown', 'latex', 'tex', 'text' } },
    'marksman',
    'yamlls',
    'texlab',
    'ccls',
    'gopls',
}

return {

    -- lsp servers package manager
    --
    -- see :h mason.nvim
    {
        'williamboman/mason.nvim',
        opts = {
            ui = {
                border = 'rounded',
            },
        },
    },

    -- integration with neovim's lspconfig
    {
        'williamboman/mason-lspconfig.nvim',
        opts = {
            ensure_installed = (function()
                local s = {}
                for _, v in pairs(servers) do
                    if v ~= 'ccls' then -- ignore ccls; mason doesn't support it
                        if type(v) ~= 'string' then
                            table.insert(s, v[1])
                        else
                            table.insert(s, v)
                        end
                    end
                end
                return s
            end)(),
        },
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
            -- border for :LspInfo
            require('lspconfig.ui.windows').default_options.border = 'rounded'

            -- custom LspAttach / LspDetach functionality for the built-in
            -- neovim lsp client
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    -- options for the nvim lsp keymaps
                    local opts = { buffer = args.buf }
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    local vlb = vim.lsp.buf

                    if client == nil then
                        return
                    end

                    -- buffer mappings for LSP servers

                    -- gD and gd below override the builtins, which makes
                    -- mappings consistent whether there is an LSP or not

                    -- goto *
                    vim.keymap.set('n', 'gD', vlb.declaration, opts)
                    vim.keymap.set('n', 'gd', vlb.definition, opts)
                    vim.keymap.set('n', '<Leader>gi', vlb.implementation, opts)
                    vim.keymap.set('n', '<Leader>gr', vlb.references, opts)
                    vim.keymap.set('n', '<Leader>td', vlb.type_definition, opts)

                    -- signature help / hover
                    vim.keymap.set('n', 'K', vlb.hover, opts)
                    vim.keymap.set('n', '<C-k>', vlb.signature_help, opts)

                    -- symbol rename
                    vim.keymap.set('n', '<Leader>rn', vlb.rename, opts)

                    -- formatting
                    vim.keymap.set('n', '<Leader>f', function()
                        vlb.format({ async = true })
                    end, opts)

                    -- code actions
                    vim.keymap.set(
                        { 'n', 'v' },
                        '<Leader>ca',
                        vlb.code_action,
                        opts
                    )

                    -- omnifunc / tagfunc completion
                    if client.server_capabilities.completionProvider then
                        vim.bo[args.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
                    end
                    if client.server_capabilities.definitionProvider then
                        vim.bo[args.buf].tagfunc = 'v:lua.vim.lsp.tagfunc'
                    end

                    -- symbol highlighting on hover
                    if client.server_capabilities.documentHighlightProvider then
                        vim.api.nvim_create_augroup(
                            'lsp_doc_highlight',
                            { clear = false }
                        )
                        vim.api.nvim_clear_autocmds({
                            buffer = args.buf,
                            group = 'lsp_doc_highlight',
                        })
                        vim.api.nvim_create_autocmd(
                            { 'CursorHold', 'CursorHoldI' },
                            {
                                buffer = args.buf,
                                group = 'lsp_doc_highlight',
                                callback = vlb.document_highlight,
                            }
                        )
                        vim.api.nvim_create_autocmd(
                            { 'CursorMoved', 'CursorMovedI' },
                            {
                                buffer = args.buf,
                                group = 'lsp_doc_highlight',
                                callback = vlb.clear_references,
                            }
                        )
                    end
                end,
                group = vim.api.nvim_create_augroup(
                    '_user_group',
                    { clear = false }
                ),
            })

            vim.api.nvim_create_autocmd('LspDetach', {
                callback = function(_)
                    -- reset omnifunc, tagfunc
                    vim.cmd('setlocal tagfunc< omnifunc<')
                end,
            })

            -- setup the lsp servers
            for _, lsp in ipairs(servers) do
                -- global opts
                local opts = {
                    capabilities = require('cmp_nvim_lsp').default_capabilities(),
                    handlers = handlers,
                    init_options = {
                        usePlaceholders = true, -- snippet expansion for func args
                    },
                }

                -- spec in the form { 'lsp_name', opt1 = {..}, opt2 = '..' } for
                -- server-specific opts
                if type(lsp) == 'table' then
                    for k, v in pairs(lsp) do
                        if type(k) == 'string' then
                            opts[k] = v
                        end
                    end
                    -- finally extract server name (should be first)
                    lsp = lsp[1]
                end

                require('lspconfig')[lsp].setup(opts)
            end
        end,
    },
}
