local editing_util = require "user.util.editing"
local keybinding_util = require "user.config.keybinding.util"
local ts_util = require "user.util.tree_sitter"

local util = require "user.config.keybinding.keymap.filetype.scheme.util"

local api = vim.api
local ts = vim.treesitter

---@param msg_name string
---@param node_type string | table<string, boolean>
---@param action fun(node: TSNode)
local function with_cursor_node(msg_name, node_type, action)
    return function()
        local node = ts_util.buf_get_cursor_node_by_type(0, "scheme", node_type)
        if node then
            action(node)
        else
            local msg = ("No %s node found under cursor"):format(msg_name)
            vim.notify(msg, vim.log.levels.INFO);
        end
    end
end

function expr_edit_mode_on()
    local mode = api.nvim_get_mode()
    if mode.mode ~= "v" then
        api.nvim_cmd({ cmd = "normal", bang = true, args = { "v" } }, {})
    end

    local dataum_edit = require "user.config.keybinding.keymap.filetype.scheme.dataum_edit"
    local state = dataum_edit.DataumEdit:new()
    state:edit_start()
end

---@param bufnr integer
return function(bufnr)
    local keymap = {
        n = {
            -- adds a new function call wrapping current expression
            ["<space>wf"] = with_cursor_node("list", "list", function(node)
                local st_r, st_c, ed_r, ed_c = ts.get_node_range(node)
                editing_util.wrap_text_range_with(st_r, st_c, ed_r, ed_c, "( ", ")", editing_util.WrapAfterPos.left)
                api.nvim_input("a")
            end),
            -- deletes current function call
            ["<space>df"] = with_cursor_node("list", "list", function(node)
                util.del_wrapping_func_call(node)
            end),
            -- appends new list sibling after current dataum node
            ["<space>a"] = with_cursor_node("dataum", util.DATAUM_TYPE_TBL, function(node)
                util.add_list_sibling_after(node)
            end),
            -- appends new linst sibling after current dataum on a new line.
            ["<space>o"] = with_cursor_node("dataum", util.DATAUM_TYPE_TBL, function(node)
                util.add_list_sibling_newline(node)
            end),
            -- entering expression editing mode
            ["<space>s"] = with_cursor_node("dataum", util.DATAUM_TYPE_TBL, function(node)
                ts_util.select_node_range(node)
                expr_edit_mode_on()
            end),
        },
        v = {
            -- entering expression editing mode
            ["<space>s"] = expr_edit_mode_on,
        },
    }

    for mode, map_tbl in pairs(keymap) do
        for from, to in pairs(map_tbl) do
            keybinding_util.map(mode, from, to, { buffer = bufnr })
        end
    end
end
