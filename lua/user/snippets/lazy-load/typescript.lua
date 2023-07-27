local cmd_snip = require "user.snippets.cmd-snippet"

local snip_filetype = "typescript"
local s = require("user.snippets.utils")
local makers = s.snippet_makers(snip_filetype)
-- local sp = makers.sp
-- local asp = makers.asp
-- local psp = makers.psp
-- local apsp = makers.apsp

-- local condsp = makers.condsp
-- local condasp = makers.condasp
-- local condpsp = makers.condpsp
-- local condapsp = makers.condapsp

-- local regsp = makers.regsp
-- local regasp = makers.regasp
-- local regpsp = makers.regpsp
-- local regapsp = makers.regapsp

cmd_snip.register {
    ["new doccom"] = {
        args = { "param-cnt" },
        content = function(param_cnt_str)
            local param_cnt = tonumber(param_cnt_str)
            if not param_cnt then
                vim.notify('invalid number: ' .. param_cnt_str, vim.log.levels.WARN)
            end

            local result = { "/**", " * " }

            for i = 1, param_cnt do
                table.insert(result, { " * @param ", i })
            end

            table.insert(result, { " * @returns ", param_cnt + 1 })

            table.insert(result, " */")

            return result
        end,
    },
}
