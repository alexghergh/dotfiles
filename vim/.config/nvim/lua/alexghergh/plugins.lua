-- Plugins ---------------------------------------------------------------------

local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

-- if packer is not installed, install it
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.api.nvim_command("packadd packer.nvim")
end

local use = require("packer").use
require("packer").startup(function()

    -- Plugin manager can manage itself
    use "wbthomason/packer.nvim"

    -- Nvim-treesitter goodies
    use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate", config = function()
            require("nvim-treesitter.configs").setup {
                hightlight = { enable = true }
            }
        end
    }

    use { "nvim-treesitter/playground", opt = true, cmd = { 'TSPlaygroundToggle' }, after = 'nvim-treesitter', config = function()
            require'nvim-treesitter.configs'.setup {
                playground = {
                    enable = true,
                    updatetime = 25, -- debounced time for highlighting nodes in the playground from source code
                    persist_queries = false, -- whether the query persists across vim sessions
                    keybindings = {
                        toggle_query_editor = 'o',
                        toggle_hl_groups = 'i',
                        toggle_injected_languages = 't',
                        toggle_anonymous_nodes = 'a',
                        toggle_language_display = 'I',
                        focus_language = 'f',
                        unfocus_language = 'F',
                        update = 'R',
                        goto_node = '<CR>',
                        show_help = '?',
                    },
                }
            }
        end
    }

    -- LSP
    use { "neovim/nvim-lspconfig", config = function()

            -- use an on_attach function to only set things up
            -- after the language server attaches to a buffer
            local custom_attach = function(client, bufnr)

                -- enable completion triggered by <C-x><C-o> in omnifunc
                vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                -- options for the nvim lsp keymaps
                local opts = { noremap = true, silent = true }

                -- go to *
                vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>gr", "<Cmd>lua vim.lsp.buf.references()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>gt", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", opts)

                -- show signature help/hover
                -- vim.api.nvim_buf_set_keymap(bufnr, 'n', "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
                -- vim.api.nvim_buf_set_keymap(bufnr, 'n', "<C-k>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", opts)

                -- actions on the buffer
                vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>ca", "<Cmd>lua vim.lsp.buf.code_action()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>=", "<Cmd>lua vim.lsp.buf.formatting()<CR>", opts)

                -- diagnostics
                vim.api.nvim_buf_set_keymap(bufnr, 'n', "<Leader>sd", "<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', "[d", "<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', "]d", "<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)

                -- compe setup
                require"compe".setup {
                    enabled = true,
                    autocomplete = true,
                    documentation = true,
                    source = {
                        path = true,
                        buffer = true,
                        nvim_lsp = true,
                        nvim_lua = true,
                        luasnip = true,
                    }
                }

                -- mappings for compe completion
                vim.api.nvim_buf_set_keymap(bufnr, 'i', "<CR>", "compe#confirm('<CR>')", { expr = true })
                vim.api.nvim_buf_set_keymap(bufnr, 'i', "<C-Space>", "compe#complete()", { expr = true })
                vim.api.nvim_buf_set_keymap(bufnr, 'i', "<C-e>", "compe#close('<C-e>')", { expr = true })

                -- draw a border around the hover and signature help boxes
                local border = {
                    { "╔", "FloatBorder" },
                    { "═", "FloatBorder" },
                    { "╗", "FloatBorder" },
                    { "║", "FloatBorder" },
                    { "╝", "FloatBorder" },
                    { "═", "FloatBorder" },
                    { "╚", "FloatBorder" },
                    { "║", "FloatBorder" },
                }

                vim.lsp.handlers["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, { border = border })
                vim.lsp.handlers["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.hover, { border = border })
            end

            -- enable function arguments completion through snippets
            -- only for lsp servers that support it
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            capabilities.textDocument.completion.completionItem.resolveSupport = {
                properties = {
                    "documentation",
                    "detail",
                    "additionalTextEdits",
                }
            }

            -- use a loop to conveniently call 'setup' on multiple servers and
            -- map buffer local keybindings when the language server attaches
            local servers = {
                "ccls",     -- c, cpp; installed through pacman ccls
                -- see github.com/MaskRay/ccls/wiki
                --"pyright",  -- python; installed through pacman pyright
                -- see github.com/microsoft/pyright
            }

            for _, lsp in ipairs(servers) do
                require'lspconfig'[lsp].setup {
                    on_attach = custom_attach,
                    capabilities = capabilities,
                    flags = {
                        debounce_text_changes = 150,
                    },
                }
            end

        end
    }

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
    -- use { "/home/alex/projects/nvim-tmux-navigation", config = function()
    use { "alexghergh/nvim-tmux-navigation", config = function()
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
        end
    }

    -- Visual selection search
    use { "bronson/vim-visual-star-search" }

    -- Commentary
    use { "tpope/vim-commentary" }

    -- Surroundings
    use { "tpope/vim-surround" }

    -- Git integration
    use { "mhinz/vim-signify", config = function()

            -- due to how the column offset is calculated for the
            -- hunk preview, a line needed to be commented in the
            -- source code so the hunk preview is aligned to the
            -- rest of the text
            -- file changed: vim-signify/autoload/sy/util.vim - L201

            -- show hunk diff preview window
            vim.api.nvim_set_keymap('n', "<Leader>sh", "<Cmd>SignifyHunkDiff<CR>", { noremap = true })

            -- hunk undo (similar to git checkout)
            vim.api.nvim_set_keymap('n', "<Leader>hu", "<Cmd>SignifyHunkUndo<CR>", { noremap = true })

            -- go to next/previous hunks
            vim.api.nvim_set_keymap('n', "]h", "<Plug>(signify-next-hunk)", {})
            vim.api.nvim_set_keymap('n', "[h", "<Plug>(signify-prev-hunk)", {})

            -- go to first/last hunks
            vim.api.nvim_set_keymap('n', "]H", "9999]h", {})
            vim.api.nvim_set_keymap('n', "[H", "9999[h", {})

            -- show the current hunk number out of total hunks
            vim.cmd[[
                autocmd User SignifyHunk call ShowCurrentHunk()

                function! ShowCurrentHunk() abort
                    let h = sy#util#get_hunk_stats()
                    if !empty(h)
                        echo printf('[Hunk %d/%d]', h.current_hunk, h.total_hunks)
                    endif
                endfunction
            ]]

            -- display the added/removed/modified lines in the statusline
            -- TODO seems to be bugged, completely overrides the default statusline
            -- however, there is no default statusline set (it is empty)
            -- so no way to tell what the initial statusline is and add to it
            vim.cmd[[
                " function! SyStatsWrapper()
                "   let [added, modified, removed] = sy#repo#get_stats()
                "   let symbols = ['+', '-', '~']
                "   let stats = [added, removed, modified]  " reorder
                "   let statline = ''

                "   for i in range(3)
                "     if stats[i] > 0
                "       let statline .= printf('%s%s ', symbols[i], stats[i])
                "     endif
                "   endfor

                "   if !empty(statline)
                "     let statline = printf('[%s]', statline[:-2])
                "   endif

                "   return statline
                " endfunction

                " function! MyStatusline()
                "   return ' %f '. SyStatsWrapper()
                " endfunction

                " set statusline=%!MyStatusline()
            ]]

            -- hunk text objects
            vim.api.nvim_set_keymap('o', "ih", "<Plug>(signify-motion-inner-pending)", {})
            vim.api.nvim_set_keymap('x', "ih", "<Plug>(signify-motion-inner-visual)", {})
            vim.api.nvim_set_keymap('o', "ah", "<Plug>(signify-motion-outer-pending)", {})
            vim.api.nvim_set_keymap('x', "ah", "<Plug>(signify-motion-outer-visual)", {})
        end
    }

    -- Modelines
    use { "alexghergh/securemodelines" }

    -- Fade inactive window
    use { "tadaa/vimade", config = function()
            vim.g.vimade = {
                enablefocusfading = 1,
                fadelevel = 0.4,
                fadepriority = 10,
                enabletreesitter = 1,
            }
        end
    }

    -- Undotree
    use { "mbbill/undotree", config = function()
            -- disable vimade when using undo tree, and reenable it afterwards
            -- for this to work, i added some commands directly to undotree
            -- lines 474 and 484 in autoload/undotree.vim

            -- show undo
            vim.api.nvim_set_keymap('n', "<Leader>su", "<Cmd>UndotreeToggle<CR>", {})

            -- window layout
            vim.g.undotree_WindowLayout = 2

            -- automatically focus the undo history when opening it
            vim.g.undotree_SetFocusWhenToggle = 1
        end
    }

    -- Easier lua keymappings
    use { "tjdevries/astronauta.nvim" }

    -- Colorschemes
    use { "savq/melange" }

end)

vim.cmd [[autocmd ColorScheme * highlight NormalFloat guibg=#1f2335]]
vim.cmd [[autocmd ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]]


-- vim: set tw=0 fo-=r
