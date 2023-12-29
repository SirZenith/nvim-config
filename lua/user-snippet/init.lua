local snip_utils = require "user-snippet.utils"

vim.api.nvim_create_user_command("SnipList", function()
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

snip_utils.load_autoload()
snip_utils.init_lazy_load()
snip_utils.init_conditional_load()
