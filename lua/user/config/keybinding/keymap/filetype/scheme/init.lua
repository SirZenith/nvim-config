local editing_util = require "user.util.editing"
local keybinding_util = require "user.config.keybinding.util"
local ts_util = require "user.util.tree_sitter"

local util = require "user.config.keybinding.keymap.filetype.scheme.util"

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

function expr_edit_mode_on()
    local mode = api.nvim_get_mode()
    if mode.mode ~= "v" then
        api.nvim_cmd({ cmd = "normal", bang = true, args = { "v" } }, {})
    end

    local list_edit = require "user.config.keybinding.keymap.filetype.scheme.list_edit"
    local state = list_edit.ListEdit:new()
    state:edit_start()
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
                util.del_wrapping_func_call(node)
            end),
            -- entering expression editing mode
            ["<space>s"] = with_cur_expr_node(function(node)
                ts_util.select_node_range(node)
                expr_edit_mode_on()
            end),
        },
        v = {
            -- wrapping selected range with extra layer of list
            ["<space>af"] = function()
                local st_r, st_c, ed_r, ed_c = editing_util.get_visual_selection_range()
                if not st_r or not st_c or not ed_r or not ed_c then return end

                vim.cmd [[execute "normal \<esc>"]]
                editing_util.wrap_text_range_with(st_r, st_c, ed_r, ed_c, "( ", ")", editing_util.WrapAfterPos.left)
                api.nvim_feedkeys("a", "n", false)
            end,
            -- entering expression editing mode
            ["<space>s"] = function()
                expr_edit_mode_on()
            end,
        },
    }

    for mode, map_tbl in pairs(keymap) do
        for from, to in pairs(map_tbl) do
            keybinding_util.map(mode, from, to, { buffer = bufnr })
        end
    end
end
