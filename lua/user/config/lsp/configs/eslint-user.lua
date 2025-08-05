local user = require "user"
local log_util = require "user.util.log"
local fs_util = require "user.util.fs"
local lsp_util = require "user.config.lsp.util"

local debug = false

local FLAT_CONFIG_NAME = {
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    "eslint.config.ts",
    "eslint.config.mts",
    "eslint.config.cts",
}

local LEGACY_CONFIG_NAME = {
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    ".eslintrc.json",
}

---@param root_dir string
---@return boolean
local function check_use_flat_config(root_dir)
    local found = false
    for _, name in ipairs(FLAT_CONFIG_NAME) do
        if vim.fn.filereadable(root_dir .. "/" .. name) == 1 then
            found = true
            break
        end
    end

    return found
end

local function resolve_node_path()
    local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
    local command = is_windows and 'where.exe node' or 'which node'

    -- Run the appropriate command to get the Node.js path
    local result = vim.fn.system(command)

    -- Trim trailing newline character(s)
    result = result:gsub("\r\n$", ""):gsub("\n$", "")

    -- Handle errors if the command fails
    if vim.v.shell_error ~= 0 then
        log_util.error("Could not find Node.js path. ESlint server will use default path.")
        return nil
    end

    return result
end

---@param root_dir string
local function get_workspace_folder(root_dir)
    return {
        uri = vim.uri_from_fname(root_dir),
        name = vim.fn.fnamemodify(root_dir, ':t'),
    }
end

local function create_cmd()
    local buffer = { "node" }

    if debug then
        table.insert(buffer, "--inspect-brk")
    end

    table.insert(buffer, fs_util.path_join(
        user.env.HOME(),
        ".local",
        "bin",
        "eslintServer.js"
    ))
    table.insert(buffer, "--stdio")

    return buffer
end

---@type vim.lsp.Config
local M = {
    cmd = create_cmd(),
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "vue",
        "svelte",
        'astro',
    },
    capabilities = {
        workspace = {
            didChangeConfiguration = {
                dynamicRegistration = true
            },
        },
    },
    settings = {
        validate = 'on',
        -- packageManager = 'pnpm',

        useESLintClass = true,
        useFlatConfig = false,
        experimental = {
            useFlatConfig = false,
        },
        codeAction = {
            disableRuleComment = {
                enable = true,
                location = 'separateLine',
            },
            showDocumentation = {
                enable = true,
            },
        },
        codeActionOnSave = {
            mode = 'all',
        },
        format = false,
        quiet = false,
        onIgnoredFiles = 'off',
        options = {},
        rulesCustomizations = {},
        run = 'onType',
        problems = {
            shortenToSingleLine = false,
        },
        nodePath = resolve_node_path(),
        workingDirectory = { mode = 'location' },
        workspaceFolder = nil,
    },
}

local function get_root_dir(fname)
    do
        local root = vim.fs.root(fname, FLAT_CONFIG_NAME)
        if root then return root end
    end

    do
        local root = vim.fs.root(fname, LEGACY_CONFIG_NAME)
        if root then return root end
    end

    do
        local root = vim.fs.root(fname, {
            "package.json,",
            ".git",
        })

        if root and root ~= vim.env.HOME then
            return root
        end
    end

    return nil
end

---@param bufnr integer
---@param on_dir fun(root_dir?: string)
function M.root_dir(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = get_root_dir(fname)
    if root then
        on_dir(root)
    end
end

function M.before_init(_params, config)
    local root_dir = config.root_dir
    if not root_dir then return end

    local settings = config.settings
    if not settings then return end

    local use_flat_config = check_use_flat_config(root_dir)
    lsp_util.upsert_config_entry(settings, "useFlatConfig", use_flat_config)
    lsp_util.upsert_config_entry(settings, "experimental.useFlatConfig", use_flat_config)

    lsp_util.upsert_config_entry(settings, "workspaceFolder", get_workspace_folder(root_dir))
end

return M
