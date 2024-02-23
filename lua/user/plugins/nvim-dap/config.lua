local user = require "user"
local fs_util = require "user.util.fs"
local log_util = require "user.util.log"

local dap_root = fs_util.path_join(user.env.APP_PATH(), "DAP")
local local_lua_root = fs_util.path_join(dap_root, "local-lua-debugger-vscode")

user.plugin.nvim_dap = {
    __newentry = true,
    adapters = {
        firefox = {
            -- git clone https://github.com/firefox-devtools/vscode-firefox-debug.git
            -- cd vscode-firefox-debug
            -- npm install
            -- npm run
            --
            -- Following options should be pay attention to before using this adaptor
            -- set those options in `about:config` page.
            --
            -- - devtools.debugger.remote-enabled, required to be `true`.
            -- - devtools.chrome.enabled, required to be `true`,
            -- - devtools.debugger.prompt-connection, recommanded to be `false`.
            -- - devtools.debugger.force-local, set to `true` only when you need
            --   debug your program from another machine.

            type = "executable",
            command = "node",
            args = {
                fs_util.path_join(dap_root, "vscode-firefox-debug", "dist", "adapter.bundle.js"),
            },
        },
        local_lua = {
            -- git clone https://github.com/tomblind/local-lua-debugger-vscode
            -- cd local-lua-debugger-vscode
            -- npm install
            -- npm run build

            type = "executable",
            command = "node",
            args = {
                fs_util.path_join(local_lua_root, "extension", "debugAdapter.js"),
            },
            enrich_config = function(config, on_config)
                if not config.extensionPath then
                    config = vim.deepcopy(config)
                    -- 💀 If this is missing or wrong you'll see
                    -- "module 'lldebugger' not found" errors in the dap-repl when trying to launch a debug session
                    config.extensionPath = local_lua_root
                end
                on_config(config)
            end,
        },
    },
    configurations = {
        lua = {
            {
                name = "Current file (local-lua-dbg, lua)",
                type = "local_lua",
                request = "launch",
                cwd = "${workspaceFolder}",
                program = {
                    lua = "lua",
                    file = "${file}",
                },
                args = {},
            },
        },
        typescript = {
            {
                -- To use debugger in attach mode, you need to start firefox with
                -- remote debuging flag.
                -- ```
                -- firefox.exe -start-debugger-server
                -- ```

                name = "Attach to Firefox",
                type = "firefox",
                request = "attach",
            },
            {
                name = "Launch Firefox Instance",
                type = "firefox",
                request = "launch",
                reAttach = true,
                url = "http://localhost:3000",
                webRoot = "${workspaceFolder}",
                firefoxExecutable = "",
            },
        },
    },
}

return user.plugin.nvim_dap:with_wrap(function(value)
    local dap = require "dap"

    -- update firefox config
    local ts_configs = value.configurations.typescript
    for _, cfg in ipairs(ts_configs) do
        if cfg.firefoxExecutable == "" then
            cfg.firefoxExecutable = user.env.FIREFOX_PATH()
        end
    end

    for key, adp in pairs(value.adapters) do
        dap.adapters[key] = adp
    end

    for key, cfg in pairs(value.configurations) do
        dap.configurations[key] = cfg
    end
end)
