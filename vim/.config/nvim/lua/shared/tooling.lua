-- tooling registry for LSP servers, formatters and linters
-- configs in this file are pulled into lua/modules/{lsp,format,lint}.lua; see also those files

-- notes:
-- - some of the formatters / linters may run in LSP mode; because of that, they accept e.g. textDocument/rangeFormatting methods
-- - packages are assumed to be installed by :Mason unless otherwise noted
-- - 'name' is the runtime config identifier used by the LSP / formatter / linter plugins (it may be different from the package name)
-- - 'package' is the actual Mason tool package; if present, overrides 'name' as the package name to use
-- - 'install' = 'ignore' marks tools that should not be auto-installed by Mason

local M = {}

-- tooling definitions per language
local languages = {
    lua = {
        filetypes = { 'lua' },
        lsp = { 'lua_ls' },
        formatters = { 'stylua' }, -- note: stylua doesn't always work in visual mode
        linters = {
            { name = 'luac', install = 'ignore' }, -- comes bundled with lua
        },
    },
    python = {
        filetypes = { 'python' },
        lsp = {
            'basedpyright',
            'ruff', -- as linter, for formatting see below and lua/modules/format.lua
        },
        formatters = {
            { name = 'ruff_fix', package = 'ruff' },
            { name = 'ruff_format', package = 'ruff' },
            -- ruff in LSP mode _does_ expose formatting imports, but as code actions
            { name = 'ruff_organize_imports', package = 'ruff' },
        },
        linters = {}, -- 'ruff' runs linting in LSP mode
    },
    c_family = {
        filetypes = { 'c', 'cpp' },
        lsp = { 'clangd' }, -- this also runs 'clang-tidy' as linter in LSP mode
        formatters = { 'clang-format' },
        linters = {
            { name = 'cppcheck', install = 'ignore' }, -- installed through package manager
        },
    },
    rust = {
        filetypes = { 'rust' },
        lsp = { 'rust_analyzer' },
        formatters = {
            { name = 'rustfmt', install = 'ignore' }, -- installed by the rust stack
        },
        linters = {
            { name = 'clippy', install = 'ignore' }, -- installed by the rust stack
        },
    },
    java = {
        filetypes = { 'java' },
        lsp = { 'jdtls' },
        formatters = { 'google-java-format' },
        linters = {},
    },
    go = {
        filetypes = { 'go' },
        lsp = { 'gopls' },
        formatters = { 'goimports', 'gofumpt' },
        linters = {},
    },
    tex_family = {
        filetypes = { 'latex', 'tex', 'plaintex', 'bib' },
        lsp = { 'texlab' },
        formatters = { 'tex-fmt' },
        linters = {
            { name = 'chktex', install = 'ignore' }, -- installed through package manager
        },
    },
    markdown = {
        filetypes = { 'markdown' },
        lsp = { 'marksman' },
        formatters = { 'mdformat' },
        linters = {},
    },
    yaml = {
        filetypes = { 'yaml' },
        lsp = { 'yamlls' },
        formatters = { 'yamlfmt' },
        linters = { 'yamllint' },
    },
    json = {
        filetypes = { 'json' },
        lsp = {},
        formatters = { 'fixjson' },
        linters = {},
    },
    fish = {
        filetypes = { 'fish' },
        lsp = { 'fish-lsp' },
        formatters = { name = 'fish_indent', install = 'ignore' }, -- installed by fish itself
        linters = {},
    },
}

-- get a tool's config name
local function tool_name(tool)
    if type(tool) == 'string' then
        return tool
    end

    return tool.name
end

-- get a tool's package name
local function tool_package(tool)
    if type(tool) == 'string' then
        return tool
    end

    return tool.package or tool.name
end

-- get a tool's installation method
local function tool_install(tool)
    if type(tool) == 'string' then
        return 'mason'
    end

    return tool.install or 'mason'
end

-- breaks the tooling definition config into proper per-language tables and returns configuration
-- dicts containing the formatted tables to pass to LSP / formatter / linter, for all languages
local function by_ft(key)
    local out = {}
    for _, lang in pairs(languages) do
        for _, ft in ipairs(lang.filetypes or {}) do
            out[ft] = vim.tbl_map(tool_name, lang[key] or {})
        end
    end
    return out
end

-- get formatter configuration; see lua/modules/format.lua
M.formatters_by_ft = function()
    return by_ft('formatters')
end

-- get linter configuration; see lua/modules/lint.lua
M.linters_by_ft = function()
    return by_ft('linters')
end

-- get LSP servers configuration; see lua/modules/lsp.lua
M.lsp_servers = function()
    local out, seen = {}, {}

    for _, lang in pairs(languages) do
        for _, tool in ipairs(lang.lsp or {}) do
            local name = tool_name(tool)

            if name ~= nil and not seen[name] then
                seen[name] = true
                table.insert(out, name)
            end
        end
    end

    return out
end

-- ensure packages are installed by Mason
-- TODO when to call the warning for manual packages that need install?
M.ensure_installed = function()
    -- collect all Mason-managed package names from the above tool definitions
    local packages = {}
    for _, key in ipairs({ 'lsp', 'formatters', 'linters' }) do
        for _, lang in pairs(languages) do
            for _, tool in ipairs(lang[key] or {}) do
                if tool_install(tool) == 'mason' then
                    local package = tool_package(tool)

                    if package ~= nil then
                        table.insert(packages, package)
                    end
                end
            end
        end
    end

    -- deduplicate package names into a unique set, to pass to Mason's ensure_installed
    local out, seen = {}, {}
    for _, package in ipairs(packages) do
        if not seen[package] then
            seen[package] = true
            table.insert(out, package)
        end
    end

    return out
end

return M
