local user = require "user"

local api = vim.api

local USER_TERMINAL_PANEL_BUF_NAME = "user.terminal"

local M = {}

---@param mode string
---@param from string
---@param to string|function
---@param opt? table
function M.map(mode, from, to, opt)
    vim.keymap.set(mode, from, to, opt)
end

function M.toggle_quickfix()
    local wins = api.nvim_tabpage_list_wins(0)
    local target
    for _, win in ipairs(wins) do
        if api.nvim_win_is_valid(win) then
            local buf = api.nvim_win_get_buf(win)

            if vim.bo[buf].filetype == "qf" then
                target = win
            end
        end
    end

    if target then
        api.nvim_win_hide(target)
    else
        vim.cmd "copen"
    end
end

function M.toggle_terminal()
    local panelpal = require "panelpal"

    local name = USER_TERMINAL_PANEL_BUF_NAME
    local buf_num, win_num = panelpal.find_buf_with_name(name)

    if not buf_num then
        -- not exists
        vim.cmd("vsplit | terminal")
        vim.cmd("keepalt file " .. name)
        vim.cmd "startinsert"
        win_num = api.nvim_get_current_win()
    elseif not win_num then
        -- not visible
        vim.cmd("vsplit")
        win_num = api.nvim_get_current_win()
        api.nvim_win_set_buf(win_num, buf_num)
        vim.cmd "startinsert"
    else
        api.nvim_win_hide(win_num)
        win_num = nil
    end

    if win_num then
        local wo = vim.wo[win_num]
        wo.number = false
        wo.relativenumber = false
    end
end

---@param is_open_in_new_tab boolean
function M.goto_cursor_file(is_open_in_new_tab)
    local cfile = vim.fn.expand "<cfile>"

    local search_targets = {}
    local path
    for _, pattern in user.keybinding.cursor_file.jump_pattern:ipairs() do
        local p = pattern:gsub("%?", cfile)
        if vim.fn.filereadable(p) == 1 then
            path = p
            break
        end
        table.insert(search_targets, p)
    end

    if not path and #search_targets > 0 then
        local buffer = { "No match found do you want to create it?" }
        for i, p in ipairs(search_targets) do
            table.insert(buffer, ("%d. %s"):format(i, p))
        end
        table.insert(buffer, "Input an index to confirm, or empty to quit: ")

        local prompt = table.concat(buffer, "\n")
        local index = tonumber(vim.fn.input(prompt))
        if index then
            path = search_targets[index]
            local dir = vim.fs.dirname(path)
            vim.cmd("!mkdir " .. dir)
        end
    end

    if path then
        local prefix = is_open_in_new_tab
            and "tabe "
            or "e "
        vim.cmd(prefix .. path)
    else
        vim.notify("No match found for: " .. cfile)
    end
end

---@param target string
function M.global_search(target)
    local make_cmd = user.keybinding.global_search.make_cmd()
    local cmd = make_cmd(target)
    api.nvim_command(cmd)
    api.nvim_command("cw")
end

---@param contents string[]
function M.append_to_eol(contents)
    local pos = api.nvim_win_get_cursor(0);
    local row = pos[1] - 1
    local col = #vim.fn.getline(pos[1])
    api.nvim_buf_set_text(0, row, col, row, col, contents)
end

function M.close_all_win_in_cur_tab()
    local all_wins = api.nvim_list_wins()
    local win_cnt = 0
    for _, win in ipairs(all_wins) do
        if vim.api.nvim_win_get_config(win).relative == '' then
            -- only counts non-floating window.
            win_cnt = win_cnt + 1
        end
    end

    local wins = api.nvim_tabpage_list_wins(0)

    local record = {}
    local ask_for_quit = false
    for _, win in ipairs(wins) do
        if not api.nvim_win_is_valid(win) then
            goto continue
        end

        local buf = api.nvim_win_get_buf(win)
        local file = api.nvim_buf_get_name(buf)

        local need_write = not record[file]
        need_write = need_write and not vim.bo[buf].readonly
        need_write = need_write and vim.bo[buf].modifiable
        need_write = need_write and vim.fn.isdirectory(file) == 0
        need_write = need_write and vim.fn.filewritable(file) ~= 0

        if need_write then
            api.nvim_win_call(win, function()
                vim.cmd "w"
            end)
            record[file] = true
        end

        if win_cnt > 1 then
            win_cnt = win_cnt - 1
            api.nvim_win_hide(win)
        else
            ask_for_quit = true
        end

        ::continue::
    end

    if ask_for_quit then
        vim.ui.input({ prompt = "Close last window and quit? (Y/N) " },
            function(input)
                if input and input:lower() == "y" then
                    vim.cmd "q"
                end
            end
        )
    end
end

return M
