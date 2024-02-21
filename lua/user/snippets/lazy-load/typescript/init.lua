local cmd_snip = require "cmd-snippet"

local log_util = require "user.util.log"
local snip_util = require "user.util.snippet"

local extract_param = require "user.snippets.lazy-load.typescript.param_extraction"

local snip_filetype = "typescript"
-- local s = require("snippet-loader.utils")
-- local makers = s.snippet_makers(snip_filetype)
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

-- ----------------------------------------------------------------------------

cmd_snip.register(snip_filetype, {
    ["disable nextline"] = {
        args = { "rule-name" },
        content = function(rule_name)
            return "// eslint-disable-next-line " .. rule_name
        end,
    },

    ["new doccom"] = {
        args = { { "param-cnt", is_optional = true } },
        content = function(param_cnt_str)
            local index = snip_util.new_jump_index()

            local param_cnt
            if param_cnt_str then
                param_cnt = tonumber(param_cnt_str)
                if not param_cnt then
                    log_util.warn("invalid number: " .. param_cnt_str)
                    return;
                end
            end

            local result = { "/**", " * " }
            if param_cnt then
                for _ = 1, param_cnt do
                    table.insert(result, { " * @param ", index() })
                end
            else
                local param_list = extract_param.extract_param()
                if param_list then
                    for _, name in ipairs(param_list) do
                        table.insert(result, { " * @param " .. name, " - ", index() })
                    end
                end
            end

            table.insert(result, { " * @returns ", index() })

            table.insert(result, " */")

            return result
        end,
    },
    ["new loop"] = {
        args = { "iter-name", "bound-name" },
        content = function(iter_name, bound_name)
            return {
                ("for (let %s = 0; %s < %s; %s++) {"):format(
                    iter_name, iter_name, bound_name, iter_name
                ),
                "",
                "}"
            }
        end,
    },
})
