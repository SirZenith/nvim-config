local user = require "user"
local panelpal = require "panelpal"

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

-- Sets LSP log level to `debug` and open a side panel for displaying LSP server"s
-- log message.
function M.lsp_server_debug_on()
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

function M.lsp_server_debug_off()
    if not M._is_debug_on then return end

    panelpal.set_panel_visibility(LOG_MESSAGE_PANEL_NAME, false)
    vim.lsp.set_log_level("warn")
    vim.lsp.handlers["window/logMessage"] = M._old_log_message_handler
end

-- ----------------------------------------------------------------------------

---@param source string # diagnostic source name
function M.disable_diagnostic_source(source)
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
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

user.lsp = {
    __new_entry = true,
    log_update_method = panelpal.PanelContentUpdateMethod.append,
    log_scroll_method = panelpal.ScrollMethod.bottom,
    on_attach_callbacks = {},
    capabilities_settings = {
        vim.lsp.protocol.make_client_capabilities()
    },
    format_args = {
        async = true
    },
    kind_label = {
        Text = "",
        Method = "",
        Function = "",
        Constructor = "",
        Field = "",
        Variable = "",
        Class = "",
        Interface = "",
        Module = "",
        Property = "",
        Unit = "",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = "",
    }
}

-- ----------------------------------------------------------------------------

return M
