local loader = require "user.config.snippet.loader"

local M = {}

local initialized = false

function M.init()
    if initialized then return end

    initialized = true

    vim.api.nvim_create_user_command("SnipList", function()
        local buffer = {}
        for filename in pairs(loader.loaded_snippets_set) do
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
end

return M
