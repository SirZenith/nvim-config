local user = require "user"
local utils = require "user.utils"
local fs = require "user.utils.fs"
local table_utils = require "user.utils.table"
local panelpal = require "panelpal"

local import = utils.import

local nvim_lsp = import "lspconfig"
local nvim_lsp_configs = import "lspconfig.configs"
local lsp_status = import "lsp-status"

local validate = vim.validate

local M = {}

-- ----------------------------------------------------------------------------

local LOG_MESSAGE_PANEL_NAME = "user.lsp.log_message"

local LspLogLevel = {
    "Trace",
    "Debug",
    "Info",
    "Warn",
    "Error",
}

M._is_debug_on = false
M._old_log_message_handler = nil

-- ----------------------------------------------------------------------------

function M.lsp_debug_on()
    vim.lsp.set_log_level("debug")

    if M._is_debug_on then return end
    M._is_debug_on = true

    local old_handler = vim.lsp.handlers["window/logMessage"]
    M._old_log_message_handler = old_handler

    vim.lsp.handlers["window/logMessage"] = function(err, result, ctx, config)
        if old_handler then
            old_handler(err, result, ctx, config)
        end

        local buf, win = panelpal.find_buf_with_name(LOG_MESSAGE_PANEL_NAME)
        if not buf then
            buf, win = panelpal.set_panel_visibility(LOG_MESSAGE_PANEL_NAME, true)
        end
        if not (buf and win) then return end

        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].modifiable = true

        local update_method = user.lsp.log_update_method()
        local log_level = LspLogLevel[result.type]

        panelpal.write_to_buf_with_highlight(
            buf, "LspLog" .. log_level,
            vim.fn.strftime("[%Y-%m-%d %X]") .. " Log Level: " .. log_level,
            update_method
        )
        panelpal.write_to_buf(buf, result.message, panelpal.PanelContentUpdateMethod.append)
        if win then
            -- offset 1 for log timestamp line
            panelpal.scroll_win(win, user.lsp.log_scroll_method(), 1)
        end

        vim.bo[buf].modifiable = false
    end
end

function M.lsp_debug_off()
    if not M._is_debug_on then return end

    panelpal.set_panel_visibility(LOG_MESSAGE_PANEL_NAME, false)
    vim.lsp.set_log_level("warn")
    vim.lsp.handlers["window/logMessage"] = M._old_log_message_handler
end

-- ----------------------------------------------------------------------------

---@param source string # diagnostic source name
function M.disable_diagnostic_source(source)
    vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
        function(_, result, ctx, config)
            local messages = {}
            for _, diag in ipairs(result.diagnostics) do
                if diag.source ~= source then
                    table.insert(messages, diag)
                end
            end
            result.diagnostics = messages
            vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
        end,
        {}
    )
end

-- ----------------------------------------------------------------------------

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
            vim.print(vim.lsp.buf.list_workspace_folders())
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
local function load_user_lsp_config(lsp_name)
    local user_config_path = fs.path_join(user.env.CONFIG_HOME(), "user", "language-server", lsp_name)
    local user_config
    if vim.fn.filereadable(user_config_path .. ".lua") == 0 then
        user_config = {}
    else
        user_config = import("user.language-server." .. lsp_name) or {}
    end

    return user_config
end

---@param lsp_name string
---@param config? table
function M.lsp_get_opt(lsp_name, config)
    local capabilities = {}
    for _, cap in user.lsp.capabilities_settings:ipairs() do
        vim.tbl_extend("force", capabilities, cap)
    end

    local default_config = {
        capabilities = capabilities,
        flags = {
            debounce_text_changes = 150,
        },
        on_attach = lsp_on_attach,
    }

    local ext = lsp_status.extensions[lsp_name]
    if ext then
        default_config.handlers = ext.setup()
    end

    local user_config = load_user_lsp_config(lsp_name)

    local final = {}
    table_utils.update_table(final, default_config)
    table_utils.update_table(final, user_config)
    table_utils.update_table(final, config or {})

    return final
end

---@param lsp_name string # name of target language server.
---@param config? table
function M.setup_lsp(lsp_name, config)
    local final_config = M.lsp_get_opt(lsp_name, config)
    nvim_lsp[lsp_name].setup(final_config)
end

---@param lsp_name string # name of target language server.
---@param config? table
function M.change_lsp_config(lsp_name, config)
    local final_config = M.lsp_get_opt(lsp_name, config)
    local lsp = nvim_lsp[lsp_name]
    local manager = lsp.manager
    local clients = manager and manager.clients() or {}

    local settings = final_config.settings
    for i = 1, #clients do
        clients[i].workspace_did_change_configuration(settings)
    end
end

---@param lsp_name string
---@param default_config table<string, any>
---@param extra_opts? table<string, any>
function M.add_lsp_config(lsp_name, default_config, extra_opts)
    validate {
        cmd = { default_config.cmd, 't' },
        filetypes = { default_config.filetypes, 't' },
        root_dir = { default_config.root_dir, 'f' },
    }

    local config = vim.tbl_deep_extend("force", {}, extra_opts or {})
    config.default_config = default_config
    nvim_lsp_configs[lsp_name] = config
end

-- ----------------------------------------------------------------------------

user.lsp = {
    log_update_method = panelpal.PanelContentUpdateMethod.append,
    log_scroll_method = panelpal.ScrollMethod.bottom,
    on_attach_callbacks = {},
    capabilities_settings = {
        vim.lsp.protocol.make_client_capabilities()
    },
    format_args = {
        async = true
    },
}

-- ----------------------------------------------------------------------------

return M
