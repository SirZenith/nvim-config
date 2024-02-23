local user = require "user"
local util = require "user.util"

local keybinding_util = require "user.config.keybinding.util"

local import = util.import

user.general.option.g = {
    mapleader = " ",
}

user.keybinding = {
    __newentry = true,
    global_search = {
        ---@type table<string, string>
        cmd_template_map = {
            default = [[:grep! `%s` %s]],
        },
        ---@type fun(targert: string)
        make_cmd = function(target)
            local platform = user.env.PLATFORM_MARK()
            local template_map = user.keybinding.global_search.cmd_template_map()
            local template = platform and template_map[platform] or template_map.default

            local paths = user.keybinding.global_search.search_paths() or { vim.fn.getcwd() }
            local quoted = {}
            for _, path in ipairs(paths) do
                quoted[#quoted + 1] = ("`%s`"):format(path)
            end

            return template:format(target, table.concat(quoted, " "))
        end,
        ---@type string[]
        search_paths = { "." },
    },
    cursor_file = {
        ---@type (string | fun(cfile: string): string?)[]
        jump_pattern = {
            "?",
            "?.lua",
            "?.h",
            "?.hpp",
            function(cfile)
                local name = vim.fs.basename(cfile)
                return "lua/user/plugins/" .. name .. "/config.lua"
            end,
        }
    },
    keymap = {
        n = require "user.config.keybinding.keymap.n",
        i = require "user.config.keybinding.keymap.i",
        v = require "user.config.keybinding.keymap.v",
        t = require "user.config.keybinding.keymap.t",
        c = require "user.config.keybinding.keymap.c",
    },
}

-- ----------------------------------------------------------------------------

return function()
    import "user.config.keybinding.build_system"

    for mode, map_tbl in user.keybinding.keymap:pairs() do
        for from, to in pairs(map_tbl) do
            keybinding_util.map(mode, from, to)
        end
    end
end
