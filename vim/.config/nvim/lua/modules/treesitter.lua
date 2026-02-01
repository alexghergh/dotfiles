return {

    -- treesitter goodies
    -- see :h treesitter
    -- see :h nvim-treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        lazy = false,
        build = function()
            require('nvim-treesitter').update():wait(300000)
        end,
        config = function()
            -- ensure the following are installed
            local languages = {
                'c',
                'cpp',
                'java',
                'latex',
                'lua',
                'python',
                'go',
                'rust',
                'query',
                'vim',
                'cmake',
                'make',
                'markdown',
                'yaml',
                'bibtex',
                'fish',
                'html',
                'vimdoc',
            }

            -- install languages (this runs async)
            require('nvim-treesitter').install(languages)

            -- show tree-sitter syntax group under cursor; mnemonic "SYntax"
            vim.keymap.set('n', '<Leader>sy', '<Cmd>Inspect<CR>', { desc = 'Show syntax / highlight under cursor' })

            -- show tree-sitter node under cursor; mnemonic "Tree-sitter Node"
            vim.keymap.set('n', '<Leader>tn', '<Cmd>InspectTree<CR>', { desc = 'Show tree-sitter editor' })

            -- parse 'tex' files as 'latex'
            vim.treesitter.language.register('latex', { 'tex' })

            -- highlighting
            vim.api.nvim_create_autocmd('FileType', {
                -- apply to
                pattern = {
                    -- the following captures exceptions like 'tex'
                    -- see vim.treesitter.language.get_filetypes()
                    table.unpack(vim.iter(languages):map(vim.treesitter.language.get_filetypes):flatten():totable()),
                },
                callback = function(ev)
                    -- disable for HUGE files
                    local disable = function()
                        local max_filesize = 500 * 1024 -- 500 KB
                        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
                        if ok and stats and stats.size > max_filesize then
                            return true
                        end
                    end

                    if not disable() then
                        -- highlights provided by neovim
                        vim.treesitter.start()

                        -- only if additional legacy syntax is needed
                        -- vim.bo[args.buf].syntax = 'on'
                    end

                    -- set folding method (provided by nvim's treesitter)
                    local win = vim.api.nvim_get_current_win()
                    if vim.wo[win][0].foldexpr == '0' then
                        vim.wo[win][0].foldmethod = 'expr'
                        vim.wo[win][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                    end

                    -- set indentation method (provided by nvim-treesitter)
                    vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
                end,
            })
        end,
    },
}
