local config_entry = require "user.utils.config_entry"
local fs = require "user.utils.fs"
local ls = require "user.config.language-server"
local snip_utils = require "user.config.snippets.utils"

local cmd = vim.api.nvim_create_user_command

---@param name string
---@param origin string
local function alias(name, origin)
    vim.cmd(("cnoreabbrev %s %s"):format(name, origin))
end

alias("Help", "tab help")
alias("tlsp", "Telescope")

-- ----------------------------------------------------------------------------

cmd("Reload", "source $MYVIMRC", {
    desc = "reload user config",
})

cmd("DumpConfigMeta", function()
    for k in pairs(package.loaded) do
        if k:starts_with("user") or k:starts_with("plugins") then
            package.loaded[k] = nil
        end
    end

    local user = require "user"
    user.finalize()

    local filepath = fs.path_join(user.env.CONFIG_HOME(), "user", "meta", "user_config.lua")
    config_entry.dump_signature(user --[[@as ConfigEntry]], filepath)
end, {
    desc = "dump user config metadata to file."
})

-- ----------------------------------------------------------------------------

cmd("LspDebugOn", function()
    ls.lsp_server_debug_on()
end, {
    desc = "turn on debug mode for LSP"
})

cmd("LspDebugOff", function()
    ls.lsp_server_debug_off()
end, {
    desc = "turn off debug mode for LSP"
})

-- ----------------------------------------------------------------------------

cmd("SnipList" , function()
    local buffer = {}
    for filename in pairs(snip_utils.loaded_snippets_set) do
        local basename = vim.fs.basename(filename)
        local name = basename:sub(-4) == ".lua"
            and basename:sub(1, -5)
            or basename
        table.insert(buffer, name)
    end

    table.sort(buffer)
    local msg = table.concat(buffer, "\n")
    vim.notify(msg)
end, {
    desc = "list all loaded snippets"
})
