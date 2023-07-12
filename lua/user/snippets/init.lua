local user = require "user"
local import = require "user.utils".import

if not import "luasnip" then
    vim.notify("snippet initialization failed")
end

local fs = require "user.utils.fs"
local snip_util = require "user.snippets.util"

return function()
    -- 注册 snippet 文件
    local autoload_group = vim.api.nvim_create_augroup("user.snippets.autoload", { clear = true })
    local snippet_dir = fs.path_join(user.env.CONFIG_HOME(), "user", "snippets", "auto-load")
    local files = fs.listdir(snippet_dir)

    for _, filename in ipairs(files) do
        snip_util.setup_autoload_cmd(autoload_group, filename)
    end
end
