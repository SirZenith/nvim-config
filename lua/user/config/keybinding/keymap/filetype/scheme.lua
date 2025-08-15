local editing_util = require "user.util.editing"
local keybinding_util = require "user.config.keybinding.util"
local ts_util = require "user.util.tree_sitter"

local api = vim.api
local ts = vim.treesitter

---@return integer? start_row
---@return integer? start_col
---@return integer? ed_row
---@return integer? ed_col
local function get_cur_expr_range()
    local node = ts_util.buf_get_cursor_node_by_type(0, "scheme", "list")
    if not node then return end
    return ts.get_node_range(node)
end

---@param action fun(start_row: integer, start_col: integer, end_row: integer, end_col: integer)
local function with_cur_expr_range(action)
    return function()
        local st_r, st_c, ed_r, ed_c = get_cur_expr_range();
        if not st_r or not st_c or not ed_r or not ed_c then
            vim.notify("No expression found under cursor", vim.log.levels.INFO);
            return
        end
        action(st_r, st_c, ed_r, ed_c)
    end
end

---@param bufnr integer
return function(bufnr)
    local keymap = {
        n = {
            -- adding a new function call wrapping current expression
            ["<space>af"] = with_cur_expr_range(function(st_r, st_c, ed_r, ed_c)
                editing_util.wrap_text_range_with(st_r, st_c, ed_r, ed_c, "( ", ")", editing_util.WrapAfterPos.left)
                api.nvim_input("a")
            end),
            -- delete current function call
            ["<space>df"] = function()
                local node = ts_util.buf_get_cursor_node_by_type(0, "scheme", "list")
                if not node then return end

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
            end,
        },
    }

    for mode, map_tbl in pairs(keymap) do
        for from, to in pairs(map_tbl) do
            keybinding_util.map(mode, from, to, { buffer = bufnr })
        end
    end
end
