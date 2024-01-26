local cmd_snip = require "cmd-snippet"

local snip_util = require "user.utils.snippet"
local ts_util = require "user.utils.tree_sitter"

local ts = vim.treesitter

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

---@type table<string, boolean>
local param_extraction_start_set = {
    accessibility_modifier = true,
    export_statement = true,
    function_declaration = true,
    lexical_declaration = true,
    method_definition = true,
    property_identifier = true,
}

---@type user.utils.TSNodeHandlerMap
local param_extraction_handler_map = {
    accessibility_modifier = function(visit_func, context, node)
        local parent = node:parent()
        if not parent then return end

        local parent_type = parent:type()
        if parent_type ~= "method_definition" then return end

        return visit_func(context, parent)
    end,

    export_statement = function(visit_func, context, node)
        local decl_node = node:field("declaration")[1]
        if not decl_node then return end

        return visit_func(context, decl_node)
    end,

    function_declaration = function(visit_func, context, node)
        local param_list_node = node:field("parameters")[1]
        if not param_list_node then
            return nil
        end

        return visit_func(context, param_list_node)
    end,

    formal_parameters = function(visit_func, context, node)
        local result = {}

        local param_cnt = node:named_child_count()
        for i = 1, param_cnt do
            local param_node = node:named_child(i - 1)
            local value = visit_func(context, param_node)

            if value then
                result[#result + 1] = value
            end
        end

        return result
    end,

    identifier = function(_, context, node)
        return ts.get_node_text(node, context.src)
    end,

    lexical_declaration = function(visit_func, context, node)
        local child_node = node:named_child(0)
        if not child_node then return end

        local child_type = child_node:type();
        if child_type ~= "variable_declarator" then return end

        return visit_func(context, child_node)
    end,

    program = function(visit_func, context, node)
        local pos = vim.api.nvim_win_get_cursor(0)
        local row, col = pos[1], pos[2]
        -- looking for function definition in next line
        local target = node:named_descendant_for_range(row, col, row, col)
        local type = target:type()

        if not param_extraction_start_set[type] then
            vim.notify("unsupported starting type: " .. type, vim.log.levels.WARN)
            return
        end

        return visit_func(context, target)
    end,

    required_parameter = function(visit_func, context, node)
        local pattern_node = node:field("pattern")[1]
        if not pattern_node then
            return nil
        end

        return visit_func(context, pattern_node)
    end,

    rest_pattern = function(visit_func, context, node)
        local child_node = node:named_child(0)
        if not child_node then
            return nil
        end

        return visit_func(context, child_node)
    end,

    this = function(_, _, _)
        return "this"
    end,

    variable_declarator = function(visit_func, context, node)
        local value_node = node:field("value")[1]
        if not value_node then return end

        local value_type = value_node:type()
        if value_type ~= "arrow_function" then return end

        return visit_func(context, value_node)
    end,
}

param_extraction_handler_map.arrow_function = param_extraction_handler_map.function_declaration
param_extraction_handler_map.method_definition = param_extraction_handler_map.function_declaration

param_extraction_handler_map.property_identifier = param_extraction_handler_map.accessibility_modifier


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
                    vim.notify("invalid number: " .. param_cnt_str, vim.log.levels.WARN)
                    return;
                end
            end

            local result = { "/**", " * " }
            if param_cnt then
                for _ = 1, param_cnt do
                    table.insert(result, { " * @param ", index() })
                end
            else
                local param_list = ts_util.visit_node_in_buffer(0, "typescript", param_extraction_handler_map)
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
