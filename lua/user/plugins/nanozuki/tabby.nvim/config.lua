local user = require "user"

local theme = {
    -- tab line background
    fill = "TabBar",
    -- header icon
    head = "TabIcon",
    -- footer icon
    tail = "TabIcon",
    -- active tab
    active = "TabActive",
    -- inactive tab
    inactive = "TabInactive",
    -- symbol for inactive tab
    sign = "TabSign",
    -- symbol for active tab
    sign_active = "TabSignActive",
    -- window status tab
    status = "TabStatus",
    -- symbol for status tab
    status_sign = "TabStatusSign",
    -- symbol for active status tab
    status_sign_active = "TabStatusSignActive",
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

return function()
    require "tabby.tabline".set(function(line)
        return {
            {
                { "  ", hl = theme.head },
                line.sep(" ", theme.head, theme.fill),
            },
            line.tabs().foreach(function(tab)
                local is_current = tab.is_current()
                local hl = is_current and theme.active or theme.inactive
                local sign = is_current and "" or ""
                local sign_hl = is_current and theme.sign_active or theme.sign
                return {
                    line.sep("", hl, theme.fill),
                    { sign, hl = sign_hl, margin = " " },
                    tab.number(),
                    str_digest(tab.name(), MAX_LEN),
                    tab.close_btn(""),
                    line.sep(" ", hl, theme.fill),
                    hl = hl,
                    margin = " ",
                }
            end),
            line.spacer(),
            line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
                local is_current = win.is_current()
                local sign = is_current and "" or ""
                local sign_hl = is_current and theme.status_sign_active or theme.status_sign_active
                return {
                    line.sep("", theme.status, theme.fill),
                    { sign, hl = sign_hl, margin = " " },
                    str_digest(win.buf_name(), MAX_LEN),
                    line.sep(" ", theme.status, theme.fill),
                    hl = theme.status,
                    margin = " ",
                }
            end),
            {
                line.sep(" ", theme.tail, theme.fill),
                { "  ", hl = theme.tail },
            },
            hl = theme.fill,
        }
    end)
end
