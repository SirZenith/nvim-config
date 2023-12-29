local lsp_status = require "lsp-status"
local lspconfig = require "lspconfig"
local lspconfigs_configs = require "lspconfig.configs"

local user = require "user"
local utils = require "user.utils"
local fs = require "user.utils.fs"
local table_utils = require "user.utils.table"

local import = utils.import

local validate = vim.validate

local M = {}

---@param client lsp.Client
---@param bufnr number
local function lsp_on_attach(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- See `:help vim.lsp.*` for documentation on any one of following functions
    local keymap = {
        -- utility
        ["<A-F>"] = function() vim.lsp.buf.format(user.lsp.format_args()) end,
        ["<F2>"] = vim.lsp.buf.rename,
        ["<space>ca"] = vim.lsp.buf.code_action,
        -- goto
        ["gd"] = vim.lsp.buf.definition,
        ["gD"] = vim.lsp.buf.declaration,
        ["gr"] = vim.lsp.buf.references,
        ["gi"] = vim.lsp.buf.implementation,
        -- diagnostic
        ["<A-n>"] = vim.diagnostic.goto_prev,
        ["<A-.>"] = vim.diagnostic.goto_next,
        ["<space>d"] = vim.diagnostic.setloclist,
        ["<space>e"] = vim.diagnostic.open_float,
        -- hover & detail
        ["K"] = vim.lsp.buf.hover,
        ["<C-k>"] = vim.lsp.buf.signature_help,
        ["<space>D"] = vim.lsp.buf.type_definition,
        -- workspace
        ["<space>wa"] = vim.lsp.buf.add_workspace_folder,
        ["<space>wr"] = vim.lsp.buf.remove_workspace_folder,
        ["<space>wl"] = function()
            local msg = table.concat(vim.lsp.buf.list_workspace_folders(), ",\n")
            vim.notify(msg)
        end,
    }

    local set = vim.keymap.set
    local opts = { noremap = true, silent = true, buffer = bufnr }
    for key, callback in pairs(keymap) do
        set("n", key, callback, opts)
    end

    --[[ if vim.fn.has("nvim-0.10") == 1 and client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint(bufnr, true)
    end ]]

    for _, callback in user.lsp.on_attach_callbacks:ipairs() do
        callback(client, bufnr)
    end
end

-- Try to find config file for given language server in user config directory.
---@param ls_name string
local function load_config_from_module(ls_name)
    local user_config_path = fs.path_join(
        user.env.CONFIG_HOME(), "user-lsp", "configs", ls_name
    )
    local user_config
    if vim.fn.filereadable(user_config_path .. ".lua") == 0 then
        user_config = {}
    else
        user_config = import("user-lsp.configs." .. ls_name) or {}
    end

    return user_config
end

-- Load config table for given language server. Resolve priority from low to high
-- will be: some basic default, config in user cnfig directory, workspace user
-- config.
---@param ls_name string
---@param user_config? table
---@return table
function M.load(ls_name, user_config)
    local config = {
        flags = {
            debounce_text_changes = 150,
        },
    }

    -- set capabilities
    local capabilities = {}
    for _, cap in user.lsp.capabilities_settings:ipairs() do
        vim.tbl_extend("force", capabilities, cap)
    end
    config.capabilities = capabilities

    -- lsp status plugin hook
    local ext = lsp_status.extensions[ls_name]
    if ext then
        config.handlers = ext.setup()
    end

    -- merging
    table_utils.update_table(config, load_config_from_module(ls_name))
    table_utils.update_table(config, user_config or {})

    -- wrapping on_attach
    local on_attach = config.on_attach
    config.on_attach = function(client, bufnr)
        lsp_on_attach(client, bufnr)

        if type(on_attach) == 'function' then
            on_attach(client, bufnr)
        end
    end

    return config
end

-- ----------------------------------------------------------------------------

-- Add server config to nvim-lspconfig
---@param ls_name string
---@param default_config table<string, any>
---@param extra_opts? table<string, any>
function M.add_lsp_config(ls_name, default_config, extra_opts)
    validate {
        cmd = { default_config.cmd, { 't', 'f' } },
        filetypes = { default_config.filetypes, 't' },
        root_dir = { default_config.root_dir, 'f' },
    }

    local config = vim.tbl_deep_extend("force", {}, extra_opts or {})
    config.default_config = default_config
    lspconfigs_configs[ls_name] = config
end

-- Update workspace setting for a language server with config passed in and config
-- in user config directory.
---@param lsp_name string # name of target language server.
---@param config? table
function M.change_workspace_setting(lsp_name, config)
    local final_config = M.lsp_get_opt(lsp_name, config)
    local cfg_obj = lspconfig[lsp_name]
    local manager = cfg_obj.manager
    local clients = manager and manager.clients() or {}

    local settings = final_config.settings
    for i = 1, #clients do
        clients[i].workspace_did_change_configuration(settings)
    end
end

return M
