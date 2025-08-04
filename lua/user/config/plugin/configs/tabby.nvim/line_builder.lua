local str_util = require "user.util.str"

local theme = require "user/config/plugin/configs/tabby.nvim/theme"

local MAX_LEN = 12

---@param tnum integer
---@param active_tnum integer
---@param tab_cnt integer
local function get_tab_side(tnum, active_tnum, tab_cnt)
    local side_right = {}

    if tnum == active_tnum then
        side_right[1] = ""

        local bg_hl = tnum == tab_cnt
            and theme.line_bg
            or theme.tab.bg

        side_right.hl = {
            fg = theme.tab_active.bg,
            bg = bg_hl,
            bold = true,
        }
    elseif tnum == active_tnum - 1 then
        side_right[1] = ""

        side_right.hl = {
            fg = theme.tab_active.bg,
            bg = theme.tab.bg,
        }
    elseif tnum ~= tab_cnt then
        side_right[1] = "╱"

        side_right.hl = {
            fg = theme.tab_fg_connector,
            bg = theme.tab.bg,
        }
    else
        side_right[1] = ""
        side_right.hl = {
            fg = theme.tab.bg,
            bg = theme.line_bg,
        }
    end

    return side_right
end

---@param wnum integer
---@param active_wnum integer
local function get_win_side(wnum, active_wnum)
    local side_left = {}

    if wnum == active_wnum then
        side_left[1] = ""

        local bg_hl = wnum == 1
            and theme.line_bg
            or theme.win_tab.bg

        side_left.hl = {
            fg = theme.win_tab_active.bg,
            bg = bg_hl,
            bold = true,
        }
    elseif wnum == active_wnum + 1 then
        side_left[1] = ""

        side_left.hl = {
            fg = theme.win_tab_active.bg,
            bg = theme.win_tab.bg,
        }
    elseif wnum ~= 1 then
        side_left[1] = "╱"

        side_left.hl = {
            fg = theme.win_tab_fg_connector,
            bg = theme.win_tab.bg,
        }
    else
        side_left[1] = ""
        side_left.hl = {
            fg = theme.win_tab.bg,
            bg = theme.line_bg,
        }
    end

    return side_left
end

---@class user.plugin.tabby.Context
---@field line table
--
---@field tabs table
---@field tab_cnt integer
---@field cur_tab table
---@field cur_tab_index integer
--
---@field wins table
---@field win_cnt integer
---@field cur_win table
---@field cur_win_index integer

---@return user.plugin.tabby.Context?
local function make_context(line)
    local tabs = line.tabs()

    local cur_tab_id = line.api.get_current_tab()
    local cur_tab
    for _, tab in ipairs(tabs.tabs) do
        if tab.id == cur_tab_id then
            cur_tab = tab
        end
    end

    if not cur_tab then
        return nil
    end

    local cur_tab_index = cur_tab.number()

    local wins = cur_tab.wins()
    local cur_win = cur_tab.current_win()
    local cur_win_id = cur_win.id
    local cur_win_index = 0
    for i, win in ipairs(wins.wins) do
        if cur_win_id == win.id then
            cur_win_index = i
        end
    end

    if cur_win_index == 0 then
        return nil
    end

    return {
        line = line,

        tabs = tabs,
        tab_cnt = #tabs.tabs,
        cur_tab = cur_tab,
        cur_tab_index = cur_tab_index,

        wins = wins,
        win_cnt = #wins.wins,
        cur_win = cur_win,
        cur_win_index = cur_win_index,
    }
end

---@param context user.plugin.tabby.Context
local function format_header(context)
    local side_fg = context.cur_tab_index == 1 and theme.tab_active.bg or theme.tab.bg;
    return {
        { "  ", hl = theme.header },
        { "", hl = { fg = side_fg, bg = theme.header.bg } },
    }
end

---@param context user.plugin.tabby.Context
local function format_tabs(context)
    local tabs = context.tabs
    local cur_active = context.cur_tab_index
    local tab_cnt = context.tab_cnt

    return tabs.foreach(function(tab)
        local tnum = tab.number()
        local is_current = tab.is_current()

        local hl = is_current and theme.tab_active or theme.tab

        local sign_hl = is_current and theme.tab_icon_active or theme.tab_icon
        local sign = { " ", tab.current_win().file_icon(), "  ", hl = sign_hl }

        return {
            sign,
            str_util.digest(tab.name(), MAX_LEN),
            tab.close_btn(" 󰅙 "),
            get_tab_side(tnum, cur_active, tab_cnt),
            hl = hl,
        }
    end)
end

---@param context user.plugin.tabby.Context
local function format_win_tabs(context)
    local wins = context.wins
    local cur_win_index = context.cur_win_index

    local result = {}

    for i, win in ipairs(wins.wins) do
        local is_current = i == cur_win_index

        local tab_hl = is_current and theme.win_tab_active or theme.win_tab

        local sign = {
            is_current and "  " or "  ",
            hl = is_current and theme.win_tab_icon_active or theme.win_tab_icon,
        }

        result[#result + 1] = {
            get_win_side(i, cur_win_index),
            sign,
            str_util.digest(win.buf_name(), MAX_LEN) .. " ",
            hl = tab_hl,
        }
    end

    return result
end

---@param context user.plugin.tabby.Context
local function format_footer(context)
    local side_bg = context.cur_win_index == context.win_cnt and theme.win_tab_active.bg or theme.win_tab.bg;
    return {
        { "", hl = { fg = theme.footer.bg, bg = side_bg } },
        { " 󱂬 ", hl = theme.footer },
    }
end

---@param line table
local function format_line(line)
    local context = make_context(line)
    if not context then
        return { hl = "" }
    end

    return {
        format_header(context),
        format_tabs(context),
        line.spacer(),
        format_win_tabs(context),
        format_footer(context),
        hl = theme.fill,
    }
end

return format_line
