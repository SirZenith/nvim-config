local user = require "user"
local utils = require "user.utils"
local fs = require "user.utils.fs"
local table_utils = require "user.utils.table"

local import = utils.import

local lspconfig = import "lspconfig"
local nvim_lsp_configs = import "lspconfig.configs"
local lsp_status = import "lsp-status"

local validate = vim.validate

local M = {}

local function lsp_on_attach(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }

    local function nmap(lhs, rhs)
        vim.keymap.set("n", lhs, rhs, opts)
    end

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local keymap = {
        -- utility
        ["<A-F>"] = function() vim.lsp.buf.format(user.lsp.format_args()) end,
        ["<F2>"] = vim.lsp.buf.rename,
        ["<space>d"] = vim.diagnostic.setloclist,
        -- goto
        ["gd"] = vim.lsp.buf.definition,
        ["gD"] = vim.lsp.buf.declaration,
        ["gr"] = vim.lsp.buf.references,
        ["gi"] = vim.lsp.buf.implementation,
        ["<A-n>"] = vim.diagnostic.goto_prev,
        ["<A-.>"] = vim.diagnostic.goto_next,
        -- hover & detail
        ["K"] = vim.lsp.buf.hover,
        ["<C-k>"] = vim.lsp.buf.signature_help,
        ["<space>e"] = vim.diagnostic.open_float,
        ["<space>ca"] = vim.lsp.buf.code_action,
        ["<space>D"] = vim.lsp.buf.type_definition,
        -- workspace
        ["<space>wa"] = vim.lsp.buf.add_workspace_folder,
        ["<space>wr"] = vim.lsp.buf.remove_workspace_folder,
        ["<space>wl"] = function()
            local msg = table.concat(vim.lsp.buf.list_workspace_folders(), ",\n")
            vim.notify(msg)
        end,
    }

    for key, callback in pairs(keymap) do
        nmap(key, callback)
    end

    for _, callback in user.lsp.on_attach_callbacks:ipairs() do
        callback(client, bufnr)
    end
end

---@param lsp_name string
local function load_config_from_module(lsp_name)
    local user_config_path = fs.path_join(
        user.env.CONFIG_HOME(), "user", "language-server", "configs", lsp_name
    )
    local user_config
    if vim.fn.filereadable(user_config_path .. ".lua") == 0 then
        user_config = {}
    else
        user_config = import("user.language-server.configs." .. lsp_name) or {}
    end

    return user_config
end

---@param lsp_name string
---@param user_config? table
function M.load(lsp_name, user_config)
    local capabilities = {}
    for _, cap in user.lsp.capabilities_settings:ipairs() do
        vim.tbl_extend("force", capabilities, cap)
    end

    local base_config = {
        capabilities = capabilities,
        flags = {
            debounce_text_changes = 150,
        },
        on_attach = lsp_on_attach,
    }

    local ext = lsp_status.extensions[lsp_name]
    if ext then
        base_config.handlers = ext.setup()
    end

    local default_config = load_config_from_module(lsp_name)

    local config = {}
    table_utils.update_table(config, base_config)
    table_utils.update_table(config, default_config)
    table_utils.update_table(config, user_config or {})

    return config
end

-- ----------------------------------------------------------------------------

---@param lsp_name string
---@param default_config table<string, any>
---@param extra_opts? table<string, any>
function M.add_lsp_config(lsp_name, default_config, extra_opts)
    validate {
        cmd = { default_config.cmd, { 't', 'f' } },
        filetypes = { default_config.filetypes, 't' },
        root_dir = { default_config.root_dir, 'f' },
    }

    local config = vim.tbl_deep_extend("force", {}, extra_opts or {})
    config.default_config = default_config
    nvim_lsp_configs[lsp_name] = config
end

---@param lsp_name string # name of target language server.
---@param user_config? table
function M.setup_lsp(lsp_name, user_config)
    local config = M.load(lsp_name, user_config)
    lspconfig[lsp_name].setup(config)
end

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
