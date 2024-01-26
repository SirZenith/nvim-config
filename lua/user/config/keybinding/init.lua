local api = vim.api
local user = require "user"
local utils = require "user.utils"
local functional = require "user.utils.functional"
local panelpal = require "panelpal"

local import = utils.import

local USER_TERMINAL_PANEL_BUF_NAME = "user.terminal"

user.option.g = {
    mapleader = " ",
}

user.keybinding = {
    global_search = {
        ---@type table<string, string>
        cmd_template_map = {
            default = [[:grep! `%s` %s]],
        },
        ---@type fun(targert: string)
        make_cmd = function(target)
            local platform = user.env.PLATFORM_MARK()
            local template_map = user.keybinding.global_search.cmd_template_map()
            local template = platform and template_map[platform] or template_map.default

            local paths = user.keybinding.global_search.search_paths() or { vim.fn.getcwd() }
            local quoted = {}
            for _, path in ipairs(paths) do
                quoted[#quoted + 1] = ("`%s`"):format(path)
            end

            return template:format(target, table.concat(quoted, " "))
        end,
        ---@type string[]
        search_paths = { "." },
    },
    cursor_file = {
        jump_pattern = {
            "?",
            "?.lua",
            "?.h",
            "?.hpp",
            "lua/user/plugins/?/config.lua",
        }
    },
}

---@param mode string
---@param from string
---@param to string|function
---@param opt? table
local function map(mode, from, to, opt)
    vim.keymap.set(mode, from, to, opt)
end

local function toggle_quickfix()
    local wins = api.nvim_tabpage_list_wins(0)
    local target
    for _, win in ipairs(wins) do
        local buf = api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "qf" then
            target = win
        end
    end

    if target then
        api.nvim_win_hide(target)
    else
        vim.cmd "copen"
    end
end

local function toggle_terminal()
    local name = USER_TERMINAL_PANEL_BUF_NAME
    local buf_num, win_num = panelpal.find_buf_with_name(name)

    if not buf_num then
        -- not exists
        vim.cmd("vsplit | terminal")
        vim.cmd("keepalt file " .. name)
        vim.cmd "startinsert"
    elseif not win_num then
        -- not visible
        vim.cmd("vsplit")
        local win = api.nvim_get_current_win()
        api.nvim_win_set_buf(win, buf_num)
        vim.cmd "startinsert"
    else
        api.nvim_win_hide(win_num)
    end
end

---@param is_open_in_new_tab boolean
local function goto_cursor_file(is_open_in_new_tab)
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
local function global_search(target)
    local make_cmd = user.keybinding.global_search.make_cmd()
    local cmd = make_cmd(target)
    api.nvim_command(cmd)
    api.nvim_command("cw")
end

---@param contents string[]
local function append_to_eol(contents)
    local pos = api.nvim_win_get_cursor(0);
    local row = pos[1] - 1
    local col = #vim.fn.getline(pos[1])
    api.nvim_buf_set_text(0, row, col, row, col, contents)
end

local function close_all_win_in_cur_tab()
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

---@alias KeyMap {[string]: string|function}

---@type KeyMap
local n_common_keymap = {
    -- Tab management
    -- new tab
    ["<C-n>"] = "<cmd>tabnew<cr>",
    -- close tab
    ["<A-w>"] = close_all_win_in_cur_tab,
    -- Editing
    ["<C-s>"] = "<cmd>w<cr>",
    ["dal"] = "0d$",
    [";;"] = function()
        append_to_eol { ";" }
    end,
    [",,"] = function()
        append_to_eol { "," }
    end,
    ["<A-up>"] = "ddkP",
    ["<A-down>"] = "ddp",
    -- Folding
    ["<Tab>"] = "za",
    -- Buffer switching
    ["<leader>b"] = ":buffer ",
    -- Searching
    ["<leader>sg"] = function()
        local target = vim.fn.input({ prompt = "Global Search: " })
        if not target or #target == 0 then return end
        global_search(target)
    end,
    -- Moving windows
    ["<A-C-h>"] = "<C-w>H",
    ["<A-C-j>"] = "<C-w>J",
    ["<A-C-k>"] = "<C-w>K",
    ["<A-C-l>"] = "<C-w>L",
    -- Toggling windows
    -- Quickfix window
    ["<leader><backspace>"] = toggle_quickfix,
    -- terminal window
    ["<C-p>"] = toggle_terminal,
    -- Moving
    -- moving between window splits
    ["<leader>n"] = "<C-w>h",
    ["<leader>."] = "<C-w>l",
    -- tab switching
    ["<leader>y"] = "gT",
    ["<leader>o"] = "gt",
    -- line movement
    ["<leader>h"] = "^",
    ["<leader>l"] = "$",
    ["<leader>j"] = "+",
    ["<leader>k"] = "-",
    -- Jumping
    -- jumping in history position
    ["<C-h>"] = "<C-o>",
    ["<C-l>"] = "<C-i>",
    -- Quick Fix jumping
    ["<A-j>"] = "<cmd>cnext<cr>",
    ["<A-k>"] = "<cmd>cprevious<cr>",
    -- jump to file
    ["gf"] = function() goto_cursor_file(true) end,
    ["<leader>gf"] = function() goto_cursor_file(false) end,
}

---@type KeyMap
local i_common_keymap = {
    ["<C-y>"] = "<esc>",
    -- Editing
    ["<C-s>"] = "<esc><cmd>w<cr>",
}

---@type KeyMap
local v_common_keymap = {
    ["<C-y>"] = "<esc>",
    -- Movement
    ["<leader>h"] = "^",
    ["<leader>l"] = "$",
    ["<leader>j"] = "+",
    ["<leader>k"] = "-",
    -- Searching
    ["<leader>sg"] = function()
        local target = panelpal.visual_selection_text()
        if not target or #target == 0 then return end
        global_search(target)
    end,
}

---@type KeyMap
local t_common_keymap = {
    ["<C-y>"] = "<C-\\><C-n>",
    -- Terminal toggle
    ["<C-p>"] = toggle_terminal,
}

---@type KeyMap
local c_common_keymap = {
    ["<C-y>"] = "<esc>",
    -- Command history
    ["<C-k>"] = "<up>",
    ["<C-j>"] = "<down>",
}

---@type {[string]: KeyMap}
local common_keymap = {
    n = n_common_keymap,
    i = i_common_keymap,
    v = v_common_keymap,
    t = t_common_keymap,
    c = c_common_keymap,
}

-- ----------------------------------------------------------------------------

return function()
    import "user.config.keybinding.build_system"

    for mode, map_tbl in pairs(common_keymap) do
        for from, to in pairs(map_tbl) do
            map(mode, from, to)
        end
    end
end
