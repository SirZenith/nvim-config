local user = require "user"
local import = require "user.utils".import

if not import "luasnip" then
    vim.notify("snippet initialization failed")
end

local fs = require "user.utils.fs"

return function()
    local snippet_group = vim.api.nvim_create_augroup("user.snippets", { clear = true })
    vim.api.nvim_create_autocmd({ "BufNewFile", "BufFilePre", "BufRead" }, {
        group = snippet_group,
        pattern = "**/user/snippets/*.lua",
        command = "set filetype=lua.snippet"
    })

    -- 加载 snippet 文件
    local snippet_dir = fs.path_join(user.env.CONFIG_HOME(), "user", "snippets")
    local files = fs.listdir(snippet_dir)
    for i = 1, #files do
        local name = vim.fs.basename(files[i])

        if name:sub(-4) == ".lua" then
            name = name:sub(1, -5)
        end

        if name ~= "init" then
            import("user/snippets/" .. name)
        end
    end

end
