local editing_util = require "user.util.editing"
local keybinding_util = require "user.config.keybinding.util"
local ts_util = require "user.util.tree_sitter"

local api = vim.api
local ts = vim.treesitter

---@param action fun(node: TSNode)
local function with_cur_expr_node(action)
    return function()
        local node = ts_util.buf_get_cursor_node_by_type(0, "scheme", "list")
        if not node then
            vim.notify("No expression found under cursor", vim.log.levels.INFO);
            return
        end
        action(node)
    end
end

-- get_parent_expression_node_for_range finds smallest expresson node that is
-- larger then specified range.
---@param st_r integer
---@param st_c integer
---@param ed_r integer
---@param ed_c integer
local function get_parent_expression_node_for_range(st_r, st_c, ed_r, ed_c)
    local parser = vim.treesitter.get_parser(0, "scheme")
    local tree_list = parser and parser:parse() or nil
    local tree = tree_list and tree_list[1] or nil
    if not tree then return end

    local root = tree:root()
    local node = root:descendant_for_range(st_r, st_c, ed_r, ed_c)
    if not node or node:id() == root:id() then return end

    return ts_util.get_parent_of_type(node, "list")
end

---@param bufnr integer
return function(bufnr)
    local keymap = {
        n = {
            -- adding a new function call wrapping current expression
            ["<space>af"] = with_cur_expr_node(function(node)
                local st_r, st_c, ed_r, ed_c = ts.get_node_range(node)
                editing_util.wrap_text_range_with(st_r, st_c, ed_r, ed_c, "( ", ")", editing_util.WrapAfterPos.left)
                api.nvim_input("a")
            end),
            -- delete current function call
            ["<space>df"] = with_cur_expr_node(function(node)
                local child_cnt = node:named_child_count()
                if child_cnt <= 0 then return end

                local children = node:named_children()

                local first_child = children[1] --[[@as TSNode]]
                if first_child:type() ~= "symbol" then
                    vim.notify("Current expression is not a function call", vim.log.levels.INFO)
                    return
                end

                local st_r, st_c, ed_r, ed_c = ts.get_node_range(node)

                local second_child = children[2]
                local last_child = children[child_cnt]
                if second_child and last_child then
                    local content_st_r, content_st_c = ts.get_node_range(second_child)
                    local _, _, content_ed_r, content_ed_c = ts.get_node_range(last_child)

                    local lines = api.nvim_buf_get_text(0, content_st_r, content_st_c, content_ed_r, content_ed_c, {})
                    api.nvim_buf_set_text(0, st_r, st_c, ed_r, ed_c, lines)
                else
                    api.nvim_buf_set_text(0, st_r, st_c, ed_r, ed_c, {})
                end
            end),
            ["<space>se"] = with_cur_expr_node(function(node)
                ts_util.select_node_range(node)
            end),
        },
        v = {
            -- adding a new function call wrapping current expression
            ["<space>af"] = function()
                api.nvim_input("<esc>")
                editing_util.wrap_selected_text_with("( ", ")", editing_util.WrapAfterPos.left)
                api.nvim_input("a")
            end,
            ["<space>se"] = function()
                local st_r, st_c, ed_r, ed_c = editing_util.get_visual_selection_range()
                if not st_r or not st_c or not ed_r or not ed_c then
                    return
                end

                local result = get_parent_expression_node_for_range(st_r, st_c, ed_r, ed_c)
                if result then
                    ts_util.select_node_range(result)
                end
            end,
        },
    }

    for mode, map_tbl in pairs(keymap) do
        for from, to in pairs(map_tbl) do
            keybinding_util.map(mode, from, to, { buffer = bufnr })
        end
    end
end
