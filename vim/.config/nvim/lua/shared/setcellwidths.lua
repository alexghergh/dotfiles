-- shared helper wrapping nvim's setcellwidths(), in order to force misbehaving glyphs to adopt
-- 2-cell widths;
--
-- the issue is that some glyphs, depending on the font, span either 1-cell or 1.5-cells; this
-- negatively interacts with nvim, since its renderer breaks the way the UI looks like;

local M = {}

-- vim.fn.setcellwidths() replaces the full table on each call and errors on overlapping ranges,
-- so a naive per-module call collides whenever two modules pick the same codepoint;
-- this helper does a range-aware get / deduplicate / set so any module can register a glyph in any
-- load order, and re-registrations are harmless no-ops
function M.add_2cellwidth_glyph(glyph)
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

return M
