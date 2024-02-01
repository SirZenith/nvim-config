local user = require "user"

local theme = {
    -- tab line background
    fill = "TabBar",

    -- header icon
    head = "TabHeader",
    -- footer icon
    tail = "TabFooter",

    -- active tab
    active = "TabActive",
    -- inactive tab
    inactive = "TabInactive",

    -- side decorator of inactive tab
    side = "TabSide",
    side_inverse = "TabSideInverse",
    -- side decorator of active tab
    side_active = "TabSideActive",
    -- side decorator of the tab next to active tab
    side_active_inverse = "TabSideActiveInverse",
    -- side decorator used between two inactive tabs
    side_continous = "TabSideContinous",

    -- symbol of inactive tab
    icon = "TabIcon",
    -- symbol of active tab
    icon_active = "TabIconActive",

    -- window tab
    win_tab = "TabWinTab",
    -- active window tab
    win_tab_active = "TabWinTabActive",
    -- symbol of window tab
    win_sign = "TabWinTabIcon",
    -- symbol of active window tab
    status_sign_active = "TabWinTabIconActive",
}

local MAX_LEN = 12

---@param text string
---@param max_len number
local function str_digest(text, max_len)
    local len = #text
    if len <= max_len then
        return text
    else
        return text:sub(1, max_len - 3) .. "..."
    end
end

---@param tnum integer
---@param active_tnum integer
local function get_tab_side_right(tnum, active_tnum, tab_cnt)
    local tab_side_right = { "" }

    if tnum == active_tnum then
        tab_side_right.hl = tnum == tab_cnt
            and theme.side_active
            or theme.side_active_inverse
    elseif tnum == active_tnum - 1 then
        tab_side_right.hl = theme.side_inverse
    elseif tnum ~= tab_cnt then
        tab_side_right[1] = ""
        tab_side_right.hl = theme.side_continous
    else
        tab_side_right.hl = theme.side
    end

    return tab_side_right
end

return function()
    require "tabby.tabline".set(function(line)
        local cur_active = 0
        local tab_cnt = 0
        local tabs = line.tabs()
        tabs.foreach(function(tab)
            if tab.is_current() then
                cur_active = tab.number()
            end
            tab_cnt = tab_cnt + 1
        end)

        return {
            {
                { "  ", hl = theme.head },
                line.sep("", theme.head, theme.fill),
            },
            tabs.foreach(function(tab)
                local tnum = tab.number()
                local is_current = tab.is_current()

                local hl = is_current and theme.active or theme.inactive

                local tab_side_hl = is_current and theme.side_active or theme.side
                local tab_side = { tnum == 1 and "" or "", hl = tab_side_hl }

                local sign_hl = is_current and theme.icon_active or theme.icon
                local sign = { " ", tab.current_win().file_icon(), "  ", hl = sign_hl }

                return {
                    tab_side,
                    sign,
                    str_digest(tab.name(), MAX_LEN),
                    tab.close_btn(" 󰅙 "),
                    get_tab_side_right(tnum, cur_active, tab_cnt),
                    hl = hl,
                }
            end),
            line.spacer(),
            line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
                local is_current = win.is_current()

                local tab_hl = is_current and theme.win_tab_active or theme.win_tab

                local sign_hl = is_current and theme.status_sign_active or theme.status_sign
                local sign = { is_current and " " or " ", hl = sign_hl }

                return {
                    line.sep("", tab_hl, theme.fill),
                    sign,
                    str_digest(win.buf_name(), MAX_LEN),
                    line.sep("█", tab_hl, theme.fill),
                    hl = tab_hl,
                }
            end),
            {
                line.sep("", theme.tail, theme.fill),
                { " 󱂬 ", hl = theme.tail },
            },
            hl = theme.fill,
        }
    end)
end
