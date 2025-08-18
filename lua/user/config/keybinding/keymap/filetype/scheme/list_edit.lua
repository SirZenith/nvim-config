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
local ListEdit = {}

local instances = {} ---@type table<integer, user.keybinding.scheme.ExprEdit?>

function ListEdit:new()
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

function ListEdit:edit_start()
    if self._is_running then return end
    self._is_running = true

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

    api.nvim_create_autocmd("ModeChanged", {
        pattern = "[vV\x16]*:*",
        once = true,
        callback = function()
            self:edit_end()
        end,
    })
end

function ListEdit:edit_end()
    self._is_running = false

    vim.notify("exit Expr Editing", vim.log.levels.INFO)

    local restore = self._restore_tbl
    if not restore then return end

    self._restore_tbl = nil

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
end

---@return table<string, function | string>
function ListEdit:get_keymap_tbl()
    return {
        -- exit expression editing mode
        ["<enter>"] = function()
            self:edit_end()
        end,

        -- expand selection to parent list of current list, if no such parent is
        -- found, it will try to select previous list sibling.
        ["h"] = function()
            local node = util.get_list_node_for_selected_range()
            if not node then return end

            local result = ts_util.get_parent_of_type(node, "list") or ts_util.get_previous_sibling_of_type(node, "list")
            if not result then return end

            ts_util.select_node_range(result)
        end,
        -- shrink selection to child list of current list, if no such child is
        -- found, it will try to select next list sibling.
        ["l"] = function()
            local node = util.get_list_node_for_selected_range()
            if not node then return end

            local result = ts_util.get_child_of_type(node, "list") or ts_util.get_next_sibling_of_type(node, "list")
            if not result then return end

            ts_util.select_node_range(result)
        end,
        -- switch selection to next sibling list, if no more list sibling is found
        -- it will try to select first child list.
        ["j"] = function()
            local node = util.get_list_node_for_selected_range()
            if not node then return end

            local result = ts_util.get_next_sibling_of_type(node, "list") or ts_util.get_child_of_type(node, "list")
            if not result then return end

            ts_util.select_node_range(result)
        end,
        -- switch selection to previous sibling list, if not list sibling is found
        -- it will try to select parent list.
        ["k"] = function()
            local node = util.get_list_node_for_selected_range()
            if not node then return end

            local result = ts_util.get_previous_sibling_of_type(node, "list") or ts_util.get_parent_of_type(node, "list")
            if not result then return end

            ts_util.select_node_range(result)
        end,

        -- wrapping selected node with extra layer of list
        ["a"] = function()
            local result = util.get_list_node_for_selected_range()
            if not result then return end

            local st_r, st_c, ed_r, ed_c = result:range()

            vim.cmd [[execute "normal \<esc>"]]
            editing_util.wrap_text_range_with(st_r, st_c, ed_r, ed_c, "( ", ")", editing_util.WrapAfterPos.left)
            api.nvim_feedkeys("a", "n", false)
        end,
        -- delete outter most layer of function call
        ["d"] = function()
            local result = util.get_list_node_for_selected_range()
            if not result then return end

            local parent_expr = ts_util.get_parent_of_type(result, "list")
            if parent_expr then
                ts_util.select_node_range(parent_expr)
            end

            util.del_wrapping_func_call(result)
        end,
    }
end

return {
    ListEdit = ListEdit,
}
