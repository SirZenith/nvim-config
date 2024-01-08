local config_entry = require "user.utils.config_entry"
local import = require "user.utils".import
local fs = require "user.utils.fs"

local api = vim.api
local cmd = api.nvim_create_user_command

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

    local filepath = fs.path_join(user.env.USER_RUNTIME_PATH(), "user", "meta", "user_config.lua")
    config_entry.dump_signature(user --[[@as ConfigEntry]], filepath)
end, {
    desc = "dump user config metadata to file."
})

cmd("ToTab", function()
    local buf = api.nvim_win_get_buf(0)
    if buf <= 0 then return end

    local old_win = api.nvim_get_current_win()

    vim.cmd "tabnew"
    api.nvim_win_set_buf(0, buf)

    api.nvim_win_hide(old_win)
end, {
    desc = "extract current buffer into new tab."
})

-- ----------------------------------------------------------------------------

cmd("SnipList", function()
    local snip_utils = import "user-snippet.utils"
    if not snip_utils then return end

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
