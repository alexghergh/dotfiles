local function map_select(key, target)
    local ntts = require('nvim-treesitter-textobjects.select')
    vim.keymap.set({ 'x', 'o' }, key, function()
        ntts.select_textobject(target, 'textobjects')
    end)
end

local function map_swap(key, textobj, target)
    local ntts = require('nvim-treesitter-textobjects.swap')
    local func
    if target == 'swap_next' then
        func = ntts.swap_next
    elseif target == 'swap_previous' then
        func = ntts.swap_previous
    else
        vim.notify("Wrong 'swap' mapping for textobjects", vim.log.levels.ERROR)
    end
    vim.keymap.set('n', key, function()
        func(textobj)
    end)
end

local function map_move(key, textobj, target)
    local ntts = require('nvim-treesitter-textobjects.move')
    local func
    if target == 'goto_next_start' then
        func = ntts.goto_next_start
    elseif target == 'goto_next_end' then
        func = ntts.goto_next_end
    elseif target == 'goto_previous_start' then
        func = ntts.goto_previous_start
    elseif target == 'goto_previous_end' then
        func = ntts.goto_previous_end
    else
        vim.notify("Wrong 'move' mapping for textobjects", vim.log.levels.ERROR)
    end
    vim.keymap.set('n', key, function()
        func(textobj)
    end)
end

return {

    -- textobjects powered selection / navigation
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        opts = {
            -- select textobjects settings
            select = {
                lookahead = true,
                include_surrounding_whitespace = false,
                selection_modes = {
                    ['@function.outer'] = 'V',
                    ['@function.inner'] = 'V',
                    ['@class.outer'] = 'V',
                    ['@class.inner'] = 'V',
                },
            },

            -- move textobjects settings
            move = {
                set_jumps = true,
            },
        },
        config = function(_, opts)
            require('nvim-treesitter-textobjects').setup(opts)

            -- select textobjects
            map_select('af', '@function.outer')
            map_select('if', '@function.inner')
            map_select('at', '@parameter.outer') -- mnemonic Term
            map_select('it', '@parameter.inner')
            map_select('ac', '@class.outer')
            map_select('ic', '@class.inner')
            map_select('al', '@loop.outer')
            map_select('il', '@loop.inner')
            -- map_select("as", "@scope.outer") -- overrides sentence textobj
            -- map_select("is", "@scope.inner")

            -- swap textobjects
            map_swap('<Leader>tp', '@parameter.inner', 'swap_previous')
            map_swap('<Leader>np', '@parameter.inner', 'swap_next')

            -- move to textobjects (pairs of [, ]); overrides neovim built-ins
            map_move(']m', '@function.outer', 'goto_next_start')
            map_move(']M', '@function.outer', 'goto_next_end')
            map_move('[m', '@function.outer', 'goto_previous_start')
            map_move('[M', '@function.outer', 'goto_previous_end')
        end,
    },
}
