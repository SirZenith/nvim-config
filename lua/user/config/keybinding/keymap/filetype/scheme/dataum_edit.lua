local editing_util = require "user.util.editing"
local keybinding_util = require "user.config.keybinding.util"
local ts_util = require "user.util.tree_sitter"
local scheme_ts_util = require "user.util.tree_sitter.scheme"

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
            local node = scheme_ts_util.get_dataum_node_for_selected_range()
            if not node then return end

            local result = ts_util.get_parent_of_type(node, scheme_ts_util.DATAUM_TYPE_TBL)
            if not result then return end

            ts_util.select_node_range(result)
        end,
        -- shrink selection to child dataum.
        ["l"] = function()
            local node = scheme_ts_util.get_dataum_node_for_selected_range()
            if not node then return end

            local result = ts_util.get_child_of_type(node, scheme_ts_util.DATAUM_TYPE_TBL)
            if not result then return end

            ts_util.select_node_range(result)
        end,
        -- switch selection to next sibling dataum.
        ["j"] = function()
            local node = scheme_ts_util.get_dataum_node_for_selected_range()
            if not node then return end

            local result = ts_util.get_next_sibling_of_type(node, scheme_ts_util.DATAUM_TYPE_TBL)
            if not result then return end

            ts_util.select_node_range(result)
        end,
        -- switch selection to previous sibling dataum.
        ["k"] = function()
            local node = scheme_ts_util.get_dataum_node_for_selected_range()
            if not node then return end

            local result = ts_util.get_previous_sibling_of_type(node, scheme_ts_util.DATAUM_TYPE_TBL)
            if not result then return end

            ts_util.select_node_range(result)
        end,

        -- expand selection range to include next sibling
        ["<C-j>"] = function()
            local st_r, st_c, ed_r, ed_c = editing_util.get_visual_selection_range()
            if not st_r or not st_c or not ed_r or not ed_c then
                return
            end

            local node = scheme_ts_util.get_dataum_node_for_range(st_r, st_c, ed_r, ed_c)
            if not node then return end

            local _, _, ned_r, ned_c = node:range()
            if ed_r > ned_r or ed_c >= ned_c then
                -- current selection range covers the whole node
                local result = ts_util.get_next_sibling_of_type(node, scheme_ts_util.DATAUM_TYPE_TBL)
                if result then
                    local _, _, red_r, red_c = result:range()
                    editing_util.set_selection_range(st_r + 1, st_c, red_r + 1, red_c - 1)
                end
            else
                -- current selection range contains in dataum node, expand selection
                -- to successive sibling.
                local pointer = node:child(0)
                while pointer do
                    if scheme_ts_util.DATAUM_TYPE_TBL[pointer:type()] then
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
        -- remove last dataum in selection range until there is only one node
        -- selected.
        ["<C-k>"] = function()
            local st_r, st_c, ed_r, ed_c = editing_util.get_visual_selection_range()
            if not st_r or not st_c or not ed_r or not ed_c then
                return
            end

            local node = scheme_ts_util.get_dataum_node_for_range(st_r, st_c, ed_r, ed_c)
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
                    if scheme_ts_util.DATAUM_TYPE_TBL[pointer:type()] then
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

        -- lift selected dataum one level upwards
        ["<A-h>"] = function()
            local node = scheme_ts_util.get_dataum_node_for_selected_range()
            if not node then return end

            local parent = node:parent()
            while parent and parent:type() ~= "list" do
                node = parent
                parent = node:parent()
            end

            if not node or not parent or parent:type() ~= "list" then
                return
            end

            local next_sibling = node:next_named_sibling() or parent:child(parent:child_count() - 1)
            if not next_sibling then return end

            local node_st_r, node_st_c, node_ed_r, node_ed_c = node:range()
            local content_st_r, content_st_c = node_st_r, node_st_c
            local content_ed_r, content_ed_c = next_sibling:range()

            local insert_r, insert_c = parent:range()

            local lines = api.nvim_buf_get_text(0, content_st_r, content_st_c, content_ed_r, content_ed_c, {})
            local line_cnt = #lines
            if line_cnt >= 2 then
                local last_line = lines[line_cnt]
                if last_line and last_line:match("%s*") == last_line then
                    lines[line_cnt] = ""
                end
            end

            api.nvim_buf_set_text(0, content_st_r, content_st_c, content_ed_r, content_ed_c, {})
            api.nvim_buf_set_text(0, insert_r, insert_c, insert_r, insert_c, lines)

            -- update visual selection

            local vst_r, vst_c = insert_r + 1, insert_c
            local ved_r, ved_c = vst_r + node_ed_r - content_st_r, node_ed_c - 1

            if content_st_r == node_ed_r then
                -- single line content, ending point should also be shifted
                ved_c = ved_c + vst_c - content_st_c
            end

            editing_util.set_selection_range(vst_r, vst_c, ved_r, ved_c)
        end,
        -- push selected dataum one level downwards
        ["<A-l>"] = function()
            local node = scheme_ts_util.get_dataum_node_for_selected_range()
            if not node then return end

            local into = nil ---@type TSNode?
            local sibling = node:next_sibling()
            while sibling do
                into = sibling:type() == "list"
                    and sibling
                    or ts_util.get_child_of_type(sibling, "list")
                if into then
                    break
                end

                sibling = sibling:next_sibling()
            end

            if not into then return end

            local first_child = into:named_child(0) or into:child(into:child_count() - 1)
            if not first_child then return end

            local node_st_r, node_st_c, node_ed_r, node_ed_c = node:range()
            local content_st_r, content_st_c = node_st_r, node_st_c
            local content_ed_r, content_ed_c = node_ed_r, node_ed_c

            local next_named = node:next_named_sibling()
            if next_named then
                content_ed_r, content_ed_c = next_named:range()
            end

            local insert_r, insert_c = first_child:range()
            local lines = api.nvim_buf_get_text(0, content_st_r, content_st_c, content_ed_r, content_ed_c, {})

            api.nvim_buf_set_text(0, insert_r, insert_c, insert_r, insert_c, lines)
            api.nvim_buf_set_text(0, content_st_r, content_st_c, content_ed_r, content_ed_c, {})

            -- update visual selection

            local line_span = content_ed_r - node_st_r

            local vst_r, vst_c = insert_r - line_span + 1, insert_c
            local ved_r, ved_c = vst_r + node_ed_r - node_st_r, node_ed_c - 1

            if content_ed_r == insert_r then
                local node_gap = insert_c - content_ed_c
                vst_c = node_st_c + node_gap
            end
            if node_st_r == node_ed_r then
                -- single line content, ending point should also be shifted
                ved_c = ved_c + vst_c - node_st_c
            end

            editing_util.set_selection_range(vst_r, vst_c, ved_r, ved_c)
        end,
        ["<A-j>"] = function()
            local node = scheme_ts_util.get_dataum_node_for_selected_range()
            if not node then return end

            local sibling = ts_util.get_next_sibling_of_type(node, scheme_ts_util.DATAUM_TYPE_TBL)
            if not sibling then return end

            local st_r, st_c, ed_r, ed_c = node:range()
            local sib_st_r, sib_st_c, sib_ed_r, sib_ed_c = sibling:range()

            local node_text = api.nvim_buf_get_text(0, st_r, st_c, ed_r, ed_c, {})
            local sibling_text = api.nvim_buf_get_text(0, sib_st_r, sib_st_c, sib_ed_r, sib_ed_c, {})

            api.nvim_buf_set_text(0, sib_st_r, sib_st_c, sib_ed_r, sib_ed_c, node_text)
            api.nvim_buf_set_text(0, st_r, st_c, ed_r, ed_c, sibling_text)

            -- update visual selection

            local line_span_delta = sib_ed_r - sib_st_r - ed_r + st_r

            local vst_r, vst_c = sib_st_r + line_span_delta + 1, sib_st_c
            local ved_r, ved_c = vst_r + ed_r - st_r, ed_c - 1
            if ed_r == sib_st_r then
                -- after switching, starting of target node and ending of sibling
                -- node will be on the same line
                local node_gap = sib_st_c - ed_c

                if sib_st_r == sib_ed_r then
                    -- single line sibling
                    local sib_len = sib_ed_c - sib_st_c
                    vst_c = st_c + sib_len + node_gap
                else
                    -- multi-line sibling
                    local col_shift = sib_ed_c - sib_st_c
                    vst_c = sib_st_c + col_shift + node_gap
                end
            end
            if vst_r == ved_r then
                -- target node has only one line of content
                ved_c = ved_c + vst_c - st_c
            end

            editing_util.set_selection_range(vst_r, vst_c, ved_r, ved_c)
        end,
        ["<A-k>"] = function()
            local node = scheme_ts_util.get_dataum_node_for_selected_range()
            if not node then return end

            local sibling = ts_util.get_previous_sibling_of_type(node, scheme_ts_util.DATAUM_TYPE_TBL)
            if not sibling then return end

            local st_r, st_c, ed_r, ed_c = node:range()
            local sib_st_r, sib_st_c, sib_ed_r, sib_ed_c = sibling:range()

            local node_text = api.nvim_buf_get_text(0, st_r, st_c, ed_r, ed_c, {})
            local sibling_text = api.nvim_buf_get_text(0, sib_st_r, sib_st_c, sib_ed_r, sib_ed_c, {})

            api.nvim_buf_set_text(0, st_r, st_c, ed_r, ed_c, sibling_text)
            api.nvim_buf_set_text(0, sib_st_r, sib_st_c, sib_ed_r, sib_ed_c, node_text)

            -- update visual selection

            local vst_r, vst_c = sib_st_r + 1, sib_st_c
            local ved_r, ved_c = vst_r + ed_r - st_r, ed_c - 1
            if vst_r == ved_r then
                ved_c = ved_c + vst_c - st_c
            end

            editing_util.set_selection_range(vst_r, vst_c, ved_r, ved_c)
        end,

        -- wrapping selected node with extra layer of list
        ["w"] = function()
            editing_util.wrap_selected_text_with("( ", ")", editing_util.WrapAfterPos.left)
            api.nvim_feedkeys("a", "n", false)
        end,
        -- delete outter most layer of function call
        ["d"] = function()
            local result = scheme_ts_util.get_dataum_node_for_selected_range()
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

            scheme_ts_util.del_wrapping_func_call(result)
        end,
        -- append a list after current dataum
        ["a"] = function()
            local node = scheme_ts_util.get_dataum_node_for_selected_range()
            if not node then return end
            scheme_ts_util.add_list_sibling_after(node)
        end,
        ["o"] = function()
            local node = scheme_ts_util.get_dataum_node_for_selected_range()
            if not node then return end
            scheme_ts_util.add_list_sibling_newline(node)
        end,
        -- indent current dataum
        ["f"] = function()
            local node = scheme_ts_util.get_dataum_node_for_selected_range()
            if not node then return end

            ts_util.select_node_range(node)
            api.nvim_cmd({ cmd = "normal", bang = true, args = { "=" } }, {})
        end,
        -- change function name used in current function call
        ["i"] = function()
            local node = scheme_ts_util.get_dataum_node_for_selected_range()
            if not node then return end

            local first_node = node:named_child(0)
            if not first_node then return end

            if first_node:type() ~= "symbol" then
                return
            end

            local st_r, st_c, ed_r, ed_c = first_node:range()
            api.nvim_win_set_cursor(0, { st_r + 1, st_c })
            api.nvim_buf_set_text(0, st_r, st_c, ed_r, ed_c, {})

            vim.cmd [[execute "normal! \<esc>\<esc>"]]
            vim.cmd [[startinsert]]
        end,
    }
end

return {
    DataumEdit = DataumEdit,
}
