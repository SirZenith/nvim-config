local cmd_snip = require "cmd-snippet"

local log_util = require "user.util.log"
local snip_util = require "user.util.snippet"

local extract_param = require "user.config.snippet.configs.lazy-load.typescript.param_extraction"

local snip_filetype = "typescript"
-- local s = require "user.config.snippet.utils"
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

local ACCESS_MODIFIER_SET = {
    private = true,
    protected = true,
    public = true,
}

-- ----------------------------------------------------------------------------

cmd_snip.register(snip_filetype, {
    ["disable nextline"] = {
        args = { "rule-name" },
        content = function(rule_name)
            return "// eslint-disable-next-line " .. rule_name
        end,
    },

    fn = {
        args = { "modifier-or-name", { "name", is_optional = true } },
        content = function(modifier_or_name, name)
            local modifier = name and modifier_or_name or ""
            name = name or modifier_or_name

            local result = "const " .. name .. " = (${2}): ${1:void} => {};"
            if modifier then
                result = modifier .. " " .. result
            end

            return result
        end,
    },

    afn = {
        args = { "modifier-or-name", { "name", is_optional = true } },
        content = function(modifier_or_name, name)
            local modifier = name and modifier_or_name or ""
            name = name or modifier_or_name

            local result = "const " .. name .. " = async (${2}): Promise<${1:void}> => {};"
            if modifier then
                result = modifier .. " " .. result
            end

            return result
        end,
    },

    ["get keys"] = {
        content = {
            { "const keys = Object.keys(", 1, ");" },
        }
    },
    ["get values"] = {
        content = {
            { "const values = Object.values(", 1, ");" },
        }
    },

    ["iter list"] = {
        args = { "name" },
        content = function(name)
            return {
                { "for (const element of ", name, ") {" },
                "}",
            }
        end,
    },
    ["iter map-entries"] = {
        args = { "name" },
        content = function(name)
            return {
                { "for (const [key, value] of ", name, ".entries()) {" },
                "}",
            }
        end,
    },
    ["iter map-keys"] = {
        args = { "name" },
        content = function(name)
            return {
                { "for (const key of ", name, ".keys()) {" },
                "}",
            }
        end,
    },
    ["iter map-values"] = {
        args = { "name" },
        content = function(name)
            return {
                { "for (const value of ", name, ".values()) {" },
                "}",
            }
        end,
    },
    ["iter object"] = {
        args = { "name" },
        content = function(name)
            return {
                { "for (const key in ",                  name, ") {" },
                { "    if (Object.hasOwnProperty.call(", name, ", key)) {" },
                "    }",
                "}",
            }
        end,
    },
    ["iter range"] = {
        args = { "iter-name", "init-name", "bound-name" },
        content = function(iter_name, init_name, bound_name)
            return {
                ("for (let %s = %s; %s < %s; %s++) {"):format(
                    iter_name, init_name,
                    iter_name, bound_name,
                    iter_name
                ),
                "",
                "}"
            }
        end,
    },

    method = {
        args = { "modifier-or-name", { "name", is_optional = true } },
        content = function(modifier_or_name, name)
            if name then
                return modifier_or_name .. " " .. name .. "(${2}): ${1:void} {}"
            end

            if ACCESS_MODIFIER_SET[modifier_or_name] then
                return modifier_or_name .. " ${1}(): void {}"
            end

            return "private " .. modifier_or_name .. "(${2}): ${1:void} {}"
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

    pri = {
        args = { "name", { "type", is_varg = true } },
        content = function(name, ...)
            return { { "private ", name, ": ", table.concat({ ... }), " = ", 1, ";" } }
        end
    },
    pro = {
        args = { "name", { "type", is_varg = true } },
        content = function(name, ...)
            return { { "protected ", name, ": ", table.concat({ ... }), " = ", 1, ";" } }
        end
    },
    pub = {
        args = { "name", { "type", is_varg = true } },
        content = function(name, ...)
            return { { "public ", name, ": ", table.concat({ ... }), " = ", 1, ";" } }
        end
    },
})
