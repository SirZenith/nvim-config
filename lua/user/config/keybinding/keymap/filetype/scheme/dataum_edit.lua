local editing_util = require "user.util.editing"
local keybinding_util = require "user.config.keybinding.util"
local ts_util = require "user.util.tree_sitter"

local util = require "user.config.keybinding.keymap.filetype.scheme.util"

local api = vim.api
local ts = vim.treesitter

---@class user.keybinding.scheme.DataumEdit
---@field _is_running boolean
---@field _restore_tbl table<string, vim.api.keyset.get_keymap | boolean>?
--
---@field bufnr integer
local DataumEdit = {}

local instances = {} ---@type table<integer, user.keybinding.scheme.DataumEdit?>

function DataumEdit:new()
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

function DataumEdit:edit_start()
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

function DataumEdit:edit_end()
    self._is_running = false

    vim.notify("exit Dataum Editing", vim.log.levels.INFO)

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
function DataumEdit:get_keymap_tbl()
    return {
        -- exit expression editing mode
        ["<enter>"] = function()
            self:edit_end()
        end,

        -- expand selection to parent dataum.
        ["h"] = function()
            local node = util.get_dataum_node_for_selected_range()
            if not node then return end

            local result = ts_util.get_parent_of_type(node, util.DATAUM_TYPE_TBL)
            if not result then return end

            ts_util.select_node_range(result)
        end,
        -- shrink selection to child dataum.
        ["l"] = function()
            local node = util.get_dataum_node_for_selected_range()
            if not node then return end

            local result = ts_util.get_child_of_type(node, util.DATAUM_TYPE_TBL)
            if not result then return end

            ts_util.select_node_range(result)
        end,
        -- switch selection to next sibling dataum.
        ["j"] = function()
            local node = util.get_dataum_node_for_selected_range()
            if not node then return end

            local result = ts_util.get_next_sibling_of_type(node, util.DATAUM_TYPE_TBL)
            if not result then return end

            ts_util.select_node_range(result)
        end,
        -- switch selection to previous sibling dataum.
        ["k"] = function()
            local node = util.get_dataum_node_for_selected_range()
            if not node then return end

            local result = ts_util.get_previous_sibling_of_type(node, util.DATAUM_TYPE_TBL)
            if not result then return end

            ts_util.select_node_range(result)
        end,

        ["<C-j>"] = function()
            local st_r, st_c, ed_r, ed_c = editing_util.get_visual_selection_range()
            if not st_r or not st_c or not ed_r or not ed_c then
                return
            end

            local node = util.get_dataum_node_for_range(st_r, st_c, ed_r, ed_c)
            if not node then return end

            local _, _, ned_r, ned_c = node:range()
            if ed_r > ned_r or ed_c >= ned_c then
                -- current selection range covers the whole node
                local result = ts_util.get_next_sibling_of_type(node, util.DATAUM_TYPE_TBL)
                if result then
                    local _, _, red_r, red_c = result:range()
                    editing_util.set_selection_range(st_r + 1, st_c, red_r + 1, red_c - 1)
                end
            else
                -- current selection range contains in dataum node, expand selection
                -- to successive sibling.
                local pointer = node:child(0)
                while pointer do
                    if util.DATAUM_TYPE_TBL[pointer:type()] then
                        local _, _, ped_r, ped_c = pointer:range()
                        if ped_r > ed_r or (ped_r == ed_r and ped_c > ed_c) then
                            editing_util.set_selection_range(st_r + 1, st_c, ped_r + 1, ped_c - 1)
                            break
                        end
                    end
                    pointer = pointer:next_sibling()
                end
            end
        end,
        ["<C-k>"] = function()
            local st_r, st_c, ed_r, ed_c = editing_util.get_visual_selection_range()
            if not st_r or not st_c or not ed_r or not ed_c then
                return
            end

            local node = util.get_dataum_node_for_range(st_r, st_c, ed_r, ed_c)
            if not node then return end

            local nst_r, nst_c, ned_r, ned_c = node:range()

            local start_covered = st_r < nst_r or (st_r == nst_r and st_c <= nst_c)
            local end_covered = ed_r > ned_r or (ed_r == ned_r and ed_c >= ned_c)
            if start_covered and end_covered then
                -- current selection covers the whole node
                editing_util.set_selection_range(nst_r + 1, nst_c, ned_r + 1, ned_c - 1)
            else
                -- current selection range contains in dataum node, shrink selection
                -- by one dataum.
                local pointer = node:child(node:child_count() - 1)
                while pointer do
                    if util.DATAUM_TYPE_TBL[pointer:type()] then
                        local pst_r, pst_c, ped_r, ped_c = pointer:range()
                        -- check if a node is fully contained inside selection
                        -- range without touching the edge of selection
                        local start_contained = st_r < pst_r or (st_r == pst_r and st_c <= pst_c)
                        local end_contained = ed_r > ped_r or (ed_r == ped_r and ed_c > ped_c)

                        if start_contained and end_contained then
                            editing_util.set_selection_range(st_r + 1, st_c, ped_r + 1, ped_c - 1)
                            break
                        end
                    end
                    pointer = pointer:prev_sibling()
                end
            end
        end,

        -- wrapping selected node with extra layer of list
        ["w"] = function()
            editing_util.wrap_selected_text_with("( ", ")", editing_util.WrapAfterPos.left)
            api.nvim_feedkeys("a", "n", false)
        end,
        -- delete outter most layer of function call
        ["d"] = function()
            local result = util.get_dataum_node_for_selected_range()
            if not result then return end

            local delete_type = "list"

            if result:type() ~= delete_type then
                result = ts_util.get_parent_of_type(result, delete_type)
                if not result then return end
            end

            local parent_expr = ts_util.get_parent_of_type(result, delete_type)
            if parent_expr then
                ts_util.select_node_range(parent_expr)
            end

            util.del_wrapping_func_call(result)
        end,
        -- append a list after current dataum
        ["a"] = function()
            local node = util.get_dataum_node_for_selected_range()
            if not node then return end
            util.add_list_sibling_after(node)
        end,
        ["o"] = function()
            local node = util.get_dataum_node_for_selected_range()
            if not node then return end
            util.add_list_sibling_newline(node)
        end,
        -- indent current dataum
        ["f"] = function()
            local node = util.get_dataum_node_for_selected_range()
            if not node then return end

            ts_util.select_node_range(node)
            api.nvim_cmd({ cmd = "normal", bang = true, args = { "=" } }, {})
        end,
    }
end

return {
    DataumEdit = DataumEdit,
}
