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
    --inactive tab
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

return function()
    local tabline = require "tabby.tabline"
    tabline.set(function(line)
        return {
            {
                { '  ', hl = theme.head },
                line.sep(' ', theme.head, theme.fill),
            },
            line.tabs().foreach(function(tab)
                local is_current = tab.is_current()
                local hl = is_current and theme.active or theme.inactive
                local sign = is_current and '' or ''
                local sign_hl = is_current and theme.sign_active or theme.sign
                return {
                    line.sep('', hl, theme.fill),
                    { sign, hl = sign_hl, margin = ' ' },
                    tab.number(),
                    tab.name(),
                    tab.close_btn(''),
                    line.sep(' ', hl, theme.fill),
                    hl = hl,
                    margin = ' ',
                }
            end),
            line.spacer(),
            line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
                local is_current = win.is_current()
                local sign = is_current and '' or ''
                local sign_hl = is_current and theme.status_sign_active or theme.status_sign_active
                return {
                    line.sep('', theme.status, theme.fill),
                    { sign, hl = sign_hl, margin = ' ' },
                    win.buf_name(),
                    line.sep(' ', theme.status, theme.fill),
                    hl = theme.status,
                    margin = ' ',
                }
            end),
            {
                line.sep(' ', theme.tail, theme.fill),
                { '  ', hl = theme.tail },
            },
            hl = theme.fill,
        }
    end)
end
