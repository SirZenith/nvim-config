local editing_util = require "user.util.editing"
local keybinding_util = require "user.config.keybinding.util"
local ts_util = require "user.util.tree_sitter"

local util = require "user.config.keybinding.keymap.filetype.scheme.util"

local api = vim.api
local ts = vim.treesitter

---@class user.keybinding.scheme.ExprEdit
---@field _is_running boolean
---@field _restore_tbl table<string, vim.api.keyset.get_keymap | boolean>?
--
---@field bufnr integer
---@field start_pos [integer, integer] # cursor position when starting editing
local ExprEdit = {}

local instances = {} ---@type table<integer, user.keybinding.scheme.ExprEdit?>

function ExprEdit:new()
    self.__index = self

    local bufnr = api.nvim_get_current_buf()

    local obj = setmetatable({}, self)

    local old_obj = instances[bufnr]
    if old_obj then
        old_obj:edit_end()
    end
    instances[bufnr] = obj

    obj._is_running = false
    obj.bufnr = bufnr

    obj:edit_start();

    return obj
end

function ExprEdit:edit_start()
    if self._is_running then return end
    self._is_running = true

    local pos = api.nvim_win_get_cursor(0)
    self.start_pos = pos

    local keymap = self:get_keymap_tbl()

    local mode = "v"
    local restore = {} ---@type table<string, vim.api.keyset.get_keymap | boolean>
    self._restore_tbl = restore

    local cur_keymap = api.nvim_buf_get_keymap(0, mode)
    for _, entry in ipairs(cur_keymap) do
        local lhs = entry.lhs
        if lhs and keymap[lhs] then
            restore[lhs] = entry
        end
    end

    local bufnr = self.bufnr
    for from, to in pairs(keymap) do
        keybinding_util.map(mode, from, to, { buffer = bufnr })

        if not restore[from] then
            restore[from] = false
        end
    end
end

function ExprEdit:edit_end()
    self._is_running = false

    vim.print("exit expr edit")

    local restore = self._restore_tbl
    if not restore then return end

    local mode = "v"
    local bufnr = self.bufnr
    instances[bufnr] = nil

    for lhs, entry in pairs(restore) do
        local entry_t = type(entry)
        if entry_t == 'table' then
            local map_to = entry.rhs or entry.callback
            if map_to then
                vim.keymap.set(mode, lhs, map_to, {
                    buffer = entry.buffer,
                    noremap = entry.noremap == 1,
                    desc = entry.desc,
                })
            else
                vim.keymap.del(mode, lhs, { buffer = bufnr })
            end
        else
            vim.keymap.del(mode, lhs, { buffer = bufnr })
        end
    end

    self._restore_tbl = nil
end

---@return table<string, function | string>
function ExprEdit:get_keymap_tbl()
    return {
        ["<enter>"] = function()
            self:edit_end()
        end,
        ["k"] = function()
            local result = util.get_expression_node_for_selected_range { force_parent = true }
            if result then
                ts_util.select_node_range(result)
            end
        end,
        ["j"] = function()
            local node = util.get_expression_node_for_selected_range()
            if not node then return end

            local row, col = self.start_pos[1], self.start_pos[2]
            local result = ts_util.find_first_containing_child_of_type(node, row - 1, col, row - 1, col, "list")

            if result then
                print(1.3)
                ts_util.select_node_range(result)
            end
        end,
        -- adding a new function call wrapping current expression
        ["a"] = function()
            api.nvim_feedkeys("<esc>", "n", false)
            editing_util.wrap_selected_text_with("( ", ")", editing_util.WrapAfterPos.left)
            api.nvim_input("a")
        end,
        ["d"] = function()
            local result = util.get_expression_node_for_selected_range { force_parent = true }
            if not result then return end

            util.del_wrapping_func_call(result)

            local node = ts_util.buf_get_cursor_node_by_type(0, "scheme", "list")
            if node then
                ts_util.select_node_range(node)
            else
                self:edit_end()
            end
        end,
    }
end

return {
    ExprEdit = ExprEdit,
}
