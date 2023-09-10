if not pcall(require, 'lspconfig') then
    return
end

--
-- language servers
--
local servers = {
    -- pacman ccls; see github.com/MaskRay/ccls/wiki
    'ccls',

    -- pacman pyright; see github.com/microsoft/pyright
    'pyright',

    -- see ~/packages folder
    'jdtls',
}

for _, lsp in ipairs(servers) do
    require('lspconfig')[lsp].setup({})
end

--
-- key-binds
--

-- use a custom LspAttach autocommand to map LSP keys only after
-- the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        -- enable completion triggered by <C-x><C-o> in omnifunc
        vim.bo[event.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- options for the nvim lsp keymaps
        local opts = { buffer = event.buf }

        -- buffer mappings for LSP servers
        -- see :h vim.lsp

        -- most of the below override the builtins, which is exactly what we
        -- want, i.e. have the same mappings whether there is an LSP-server
        -- present or not

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
        vim.keymap.set('n', '<space>f', function() -- <L>=
            vim.lsp.buf.format { async = true }
        end, opts)

        -- code actions
        vim.keymap.set({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action, opts)

        -- workspace folders
        -- vim.keymap.set('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
        -- vim.keymap.set('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
        -- vim.keymap.set('n', '<Leader>ww', function()
        --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        -- end, opts)
        -- vim.keymap.set('n', '<Leader>ws', vim.lsp.buf.workspace_symbol, opts)
    end,
    group = vim.api.nvim_create_augroup('_user_group', { clear = false })
})

--
-- UI customization and other settings
--

-- set up borders for hover and signature help by overriding the built-in
-- vim.lsp.util.open_floating_preview(), globally
local orig_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or 'rounded'
    return orig_open_floating_preview(contents, syntax, opts, ...)
end

-- set up completion kinds icons
icons = {
    Class = " ",
    Color = " ",
    Constant = " ",
    Constructor = " ",
    Enum = "了 ",
    EnumMember = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = " ",
    Interface = "ﰮ ",
    Keyword = " ",
    Method = "ƒ ",
    Module = " ",
    Property = " ",
    Snippet = "﬌ ",
    Struct = " ",
    Text = " ",
    Unit = " ",
    Value = " ",
    Variable = " ",
}

local kinds = vim.lsp.protocol.CompletionItemKind
for i, kind in ipairs(kinds) do
    kinds[i] = icons[kind] or kind
end

-- go to definition in a split window
local function goto_definition(split_cmd)
    local util = vim.lsp.util
    local log = require("vim.lsp.log")
    local api = vim.api

    local handler = function(_, result, ctx)
        if result == nil or vim.tbl_isempty(result) then
            local _ = log.info() and log.info(ctx.method, "No location found")
            return nil
        end

        if split_cmd then
            vim.cmd(split_cmd)
        end

        if vim.tbl_islist(result) then
            util.jump_to_location(result[1])

            if #result > 1 then
                util.set_qflist(util.locations_to_items(result))
                api.nvim_command("copen")
                api.nvim_command("wincmd p")
            end
        else
            util.jump_to_location(result)
        end
    end

    return handler
end

vim.lsp.handlers["textDocument/definition"] = goto_definition('vsplit')

-- TODO this should be in the above "LspAttach", in order to automatically check
-- client capabilities (see
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization, last tip)
-- vim.cmd[[
-- autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
-- autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
-- autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
-- ]]

--     -- compe setup
--     require"compe".setup {
--         enabled = true,
--         autocomplete = true,
--         documentation = true,
--         source = {
--             path = true,
--             buffer = true,
--             nvim_lsp = true,
--             nvim_lua = true,
--             luasnip = true,
--         }
--     }

--     -- mappings for compe completion
--     vim.api.nvim_buf_set_keymap(bufnr, 'i', "<CR>", "compe#confirm('<CR>')", { expr = true })
--     vim.api.nvim_buf_set_keymap(bufnr, 'i', "<C-Space>", "compe#complete()", { expr = true })
--     vim.api.nvim_buf_set_keymap(bufnr, 'i', "<C-e>", "compe#close('<C-e>')", { expr = true })

-- -- enable function arguments completion through snippets
-- -- only for lsp servers that support it
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.textDocument.completion.completionItem.snippetSupport = true
-- capabilities.textDocument.completion.completionItem.resolveSupport = {
--     properties = {
--         "documentation",
--         "detail",
--         "additionalTextEdits",
--     }
-- }
