local user = require "user"
local fs = require "user.utils.fs"

local local_lua_root = fs.path_join(user.env.LANG_PATH(), "Lua", "local-lua-debugger-vscode")
local adapter_local_lua = {
    type = "executable",
    command = "node",
    args = {
        fs.path_join(local_lua_root, "extension", "debugAdapter.js"),
    },
    enrich_config = function(config, on_config)
        if not config["extensionPath"] then
            local c = vim.deepcopy(config)
            -- 💀 If this is missing or wrong you'll see
            -- "module 'lldebugger' not found" errors in the dap-repl when trying to launch a debug session
            c.extensionPath = local_lua_root
            on_config(c)
        else
            on_config(config)
        end
    end,
}

user.plugin.nvim_dap = {
    __new_entry = true,

    adapters = {
        ["local-lua"] = adapter_local_lua,
    },

    configurations = {
        lua = {
            {
                name = "Current file (local-lua-dbg, lua)",
                type = "local-lua",
                request = "launch",
                cwd = "${workspaceFolder}",
                program = {
                    lua = "lua",
                    file = "${file}",
                },
                args = {},
            },
        },
    },
}

return function()
    local dap = require "dap"

    local config = user.plugin.nvim_dap

    for key, value in config.adapters:pairs() do
        dap.adapters[key] = value
    end

    for key, value in config.configurations:pairs() do
        dap.configurations[key] = value
    end
end
