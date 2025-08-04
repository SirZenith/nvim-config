local user = require "user"
local fs_util = require "user.util.fs"
local log_util = require "user.util.log"

local command = require "user.config.lsp.command"

command.init()

---@return table
local function merge_capabilities()
    local capabilities = {}

    for _, cap in user.lsp.capabilities_list:ipairs() do
        local cap_t = type(cap)
        if cap_t == "table" then
            capabilities = vim.tbl_extend("force", capabilities, cap)
        elseif cap_t == "function" then
            capabilities = vim.tbl_extend("force", capabilities, cap())
        end
    end

    return capabilities;
end

---@param config table
---@return table
local function wrap_on_attach(config)
    local on_attach = config.on_attach
    config.on_attach = function(client, bufnr)
        for _, callback in user.lsp.on_attach_callbacks:ipairs() do
            callback(client, bufnr)
        end

        if type(on_attach) == 'function' then
            on_attach(client, bufnr)
        end
    end

    return config
end

-- merging LSP config from different source.
---@param name string
local function merge_lsp_config(name)
    local loader = require "user.config.lsp.loader"

    local config_overlay = user.lsp.server_config[name]()
    if type(config_overlay) == "function" then
        config_overlay = config_overlay()
    end

    local root_path = fs_util.path_join(user.env.USER_RUNTIME_PATH(), "user", "config", "lsp", "configs")
    local config_module = loader.load(root_path, name)

    local result = vim.tbl_deep_extend(
        "force",
        {
            flags = {
                debounce_text_changes = 150,
            },
        },
        config_module,
        config_overlay or {},
        {
            capabilities = merge_capabilities(),
        }
    )

    return result
end

for _, info in user.lsp.server_list:ipairs() do
    if info.enabled ~= false then
        local name = type(info) == "string" and info or info[1]

        local config = merge_lsp_config(name)
        config = wrap_on_attach(config)

        vim.lsp.enable(name)
        vim.lsp.config(name, config)
    end
end
