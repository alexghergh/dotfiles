-- every glyph the config draws, grouped by where it shows up
--
-- `widen = true` registers the glyph as 2 cells wide; depending on the font, nerd-font icons and
-- emoji draw at 1 or 1.5 cells, while nvim assumes 1, which breaks the UI around them; the module
-- exposes plain strings, e.g. `require('shared.glyphs').diagnostics.error`

-- stylua: ignore
local groups = {
    -- terminal title (OSC 2), see lua/core/settings.lua
    nvim = {
        logo                        = { '', widen = true },
    },

    -- signs and virtual text, see lua/core/diagnostics.lua
    diagnostics = {
        error                       = { '󰅚', widen = true },
        warn                        = { '󰀪', widen = true },
        hint                        = { '󰌶', widen = true },
        info                        = { '', widen = true },
        virt_text_prefix            = { '●', widen = true },
    },

    -- codecompanion, see lua/modules/ai.lua and lua/modules/statusline.lua
    codecompanion = {
        -- adapters
        codex                       = { '', widen = true },
        claude_code                 = { '', widen = true },

        -- chat status; the spinner is a list of animation frames, true 1-cell
        spinner                     = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏', widen = false },
        chat_ready                  = { '', widen = true },
        pending_tool_approval       = { '󰀪', widen = true },

        -- wezterm tab attention markers (OSC 2); clear on window focus
        tool_attention_marker       = { '🔴', widen = true },
        finished_attention_marker   = { '🟢', widen = true },

        -- chat header icons, drawn on the "## Me" / "## CodeCompanion" lines
        header_cap                  = { '', widen = false },

        -- chat sub-header icons, drawn on the "### Reasoning" / "### Response" lines
        reasoning                   = { '󰧑', widen = true },
        response                    = { '󰭹', widen = true },
        subhead_separator           = { '─', widen = false },
    },
}

-- vim.fn.setcellwidths() replaces the full table on each call and errors on overlapping ranges,
-- so this does a range-aware get / deduplicate / set; glyphs shared between groups register once
local function add_2cellwidth_glyph(glyph)
    local c = vim.fn.char2nr(glyph)
    local existing = vim.fn.getcellwidths()
    for _, e in ipairs(existing) do
        if c >= e[1] and c <= e[2] then
            return
        end
    end
    existing[#existing + 1] = { c, c, 2 }
    vim.fn.setcellwidths(existing)
end

local M = {}
for group_name, group in pairs(groups) do
    M[group_name] = {}
    for name, glyph in pairs(group) do
        for _, frame in ipairs(glyph) do
            if glyph.widen then
                add_2cellwidth_glyph(frame)
            end
        end
        -- a single glyph becomes a string, a list of frames stays a list
        M[group_name][name] = #glyph > 1 and { unpack(glyph) } or glyph[1]
    end
end

return M
