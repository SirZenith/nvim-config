local utils = require "user.utils"
local import = utils.import
local fs = require "user.utils.fs"
local ConfigEntry = require "user.config_entry".ConfigEntry

local env_config_home = vim.env.CONFIG_HOME
if  not env_config_home then
    vim.notify("failed to initialize, Can't find environment varialbe 'CONFIG_HOME'")
    return
end

local user = ConfigEntry:new {
    env = {
        NVIM_HOME = fs.path_join(env_config_home, "nvim"),
        CONFIG_HOME = fs.path_join(env_config_home, "nvim", "lua"),
    }
}

-- 将 user 命名空间下的设置加载到 vim 的命名空间中。
---@param key string|string[] # 若传入字符串列表，则列表中每个字符串是一个目标键
local function load_into_vim(key)
    if type(key) == "string" then
        key = { key }
    end

    for _, k in ipairs(key) do
        local optioins = user[k]
        if not optioins then return end

        local target = vim[k]
        for field, value in optioins:pairs() do
            target[field] = value
        end
    end
end

-- 跳转到首个打开的文件所在的目录，这一目录将作为本次启动的工作区
local function chdir()
    local output = vim.api.nvim_command_output "args"
    local cur_file = output:match("%[(.+)%]")

    local dir_path
    if vim.fn.isdirectory(cur_file) == 1 then
        dir_path = cur_file
    elseif vim.fn.filereadable(cur_file) == 1 then
        dir_path = vim.fs.dirname(cur_file)
    end

    if dir_path then
        vim.fn.chdir(dir_path)
    end
end

rawset(user, "finalize", function()
    chdir()

    -- 加载自定义模块 loader
    require "user.utils.module_loaders"

    local modules = {
        -- 加载插件，保证其它配置文件中可以引用各个插件
        import "user.plugins",

        -- 用户设定
        import "user.command",
        import "user.general",
        import "user.keybinding",
        import "user.snippets",

        -- 平台限定设定
        import "user.platforms",

        -- 工作区设定
        import "user.workspace".load(),
    }

    -- 确定 vim 相关设定
    load_into_vim { "o", "wo", "g", "go" }

    -- 各组件的配置定稿化
    utils.finalize(modules)
end)

return user
