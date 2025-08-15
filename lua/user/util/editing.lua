local M = {}

local api = vim.api

---@return integer? row_st # 0-base index
---@return integer? col_st # 0-base index
---@return integer? row_ed # 0-base index
---@return integer? col_ed # 0-base index
function M.get_visual_selection_range()
    local unpac = unpack or table.unpack
    local st_r, st_c, ed_r, ed_c

    local cur_mode = api.nvim_get_mode().mode
    if cur_mode == "v" then
        _, st_r, st_c, _ = unpac(vim.fn.getpos("v"))
        _, ed_r, ed_c, _ = unpac(vim.fn.getpos("."))
    else
        _, st_r, st_c, _ = unpac(vim.fn.getpos("'<"))
        _, ed_r, ed_c, _ = unpac(vim.fn.getpos("'>"))
    end

    if
        not (st_r and st_c and ed_r and ed_c)
        or st_r * st_c * ed_r * ed_c == 0
    then
        return nil
    end

    if st_r < ed_r or (st_r == ed_r and st_c <= ed_c) then
        return st_r - 1, st_c - 1, ed_r - 1, ed_c
    else
        return ed_r - 1, ed_c - 1, st_r - 1, st_c
    end
end

---@enum user.util.WrapAfterPos
local WrapAfterPos = {
    keep = 0,
    left = 1,
    right = 2,
}
M.WrapAfterPos = WrapAfterPos

---@param start_row integer # 0-base index
---@param start_col integer # 0-base index
---@param end_row integer # 0-base index
---@param end_col integer # 0-base index
---@param left string
---@param right string
---@param follow_type user.util.WrapAfterPos # where to put cursort after adding contents
function M.wrap_text_range_with(start_row, start_col, end_row, end_col, left, right, follow_type)
    local winnr = 0
    local bufnr = api.nvim_win_get_buf(winnr)
    local old_pos = api.nvim_win_get_cursor(winnr)

    local ed_line = api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, true)[1]
    if not ed_line then return end

    -- make sure not to insert content in the middle unicode character.
    local end_offset = end_col + vim.str_utf_end(ed_line, end_col)

    local end_pos = { end_row + 1, end_offset }
    api.nvim_win_set_cursor(winnr, end_pos)
    api.nvim_put({ right }, "c", true, false)

    local start_pos = { start_row + 1, start_col }
    api.nvim_win_set_cursor(winnr, start_pos)
    api.nvim_put({ left }, "c", false, false)

    if follow_type == WrapAfterPos.keep then
        if old_pos[1] == start_pos[1] then
            old_pos[2] = old_pos[2] + #left
        end
        api.nvim_win_set_cursor(winnr, old_pos)
    elseif follow_type == WrapAfterPos.left then
        api.nvim_win_set_cursor(winnr, start_pos)
    elseif follow_type == WrapAfterPos.right then
        if end_pos[1] == start_pos[1] then
            end_pos[2] = end_pos[2] + #left
        end
        api.nvim_win_set_cursor(winnr, end_pos)
    end
end

-- wrap_selected_text_with adds given content to the left and right side of selected
-- part of buffer text.
---@param left string
---@param right string
function M.wrap_selected_text_with(left, right)
    local st_r, st_c, ed_r, ed_c = M.get_visual_selection_range()
    if not st_r or not st_c or not ed_r or not ed_c then return end

    M.wrap_text_range_with(st_r, st_c, ed_r, ed_c, left, right, WrapAfterPos.keep)
end

return M
