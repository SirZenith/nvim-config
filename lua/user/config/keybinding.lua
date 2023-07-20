local api = vim.api
local user = require "user"
local functional = require "user.utils.functional"
local panelpal = require "panelpal"

local USER_TERMINAL_PANEL_BUF_NAME = "user.terminal"

user.keybinding = {
    global_search = {
        ---@type table<string, string>
        cmd_template_map = {
            default = [[:grep! `%s` %s]],
        },
        ---@type fun(targert: string)
        make_cmd = function(target)
            local platform = vim.env.PLATFORM_MARK
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
            "user/plugins/?/config.lua",
        }
    },
}

local KEYBINDING_AUGROUP = api.nvim_create_augroup("user.keybinding", { clear = true })

---@param mode string
---@param from string
---@param to string|function
---@param opt? table
local function map(mode, from, to, opt)
    vim.keymap.set(mode, from, to, opt)
end

---@param from string
---@param to string|function
---@param opt? table
local function nmap(from, to, opt)
    map("n", from, to, opt)
end

---@param from string
---@param to string|function
---@param opt? table
local function imap(from, to, opt)
    map("i", from, to, opt)
end

---@param from string
---@param to string|function
---@param opt? table
local function vmap(from, to, opt)
    map("v", from, to, opt)
end

---@param from string
---@param to string|function
---@param opt? table
local function tmap(from, to, opt)
    map("t", from, to, opt)
end

---@param from string
---@param to string|function
---@param opt? table
local function cmap(from, to, opt)
    map("c", from, to, opt)
end

local function toggle_quickfix()
    local is_visible = functional.any(
        panelpal.list_visible_buf(0),
        function(_, buf) return vim.bo[buf].filetype == "qf" end
    )
    vim.cmd(is_visible and "cclose" or "copen")
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

---@param filetype string|string[]
---@param mapto string|function
local function register_build_mapping(filetype, mapto)
    api.nvim_create_autocmd("FileType", {
        group = KEYBINDING_AUGROUP,
        pattern = filetype,
        callback = function()
            nmap("<A-b>", mapto, { buffer = true })
        end
    })
end

---@alias KeyMap {[string]: string|function}

---@type KeyMap
local n_common_keymap = {
    -- Tab management
    -- new tab
    ["<C-n>"] = "<cmd>tabnew<cr>",
    -- close tab
    ["<A-w>"] = function()
        local wins = api.nvim_tabpage_list_wins(0)

        local record = {}
        for _, win in ipairs(wins) do
            local buf = api.nvim_win_get_buf(win)
            local file = api.nvim_buf_get_name(buf)
            if not record[file] and vim.fn.filewritable(file) == 1 then
                api.nvim_set_current_win(win)
                vim.cmd "w"
                record[file] = true
            end
        end

        local tabpages = api.nvim_list_tabpages()
        vim.cmd(#tabpages > 1 and "tabclose" or "q")
    end,
    -- Editing
    ["<C-s>"] = "<cmd>w<cr>",
    ["dal"] = "0d$",
    [";;"] = "<esc>A;<esc>",
    [",,"] = "<esc>A,<esc>",
    ["<A-up>"] = "ddkP",
    ["<A-down>"] = "ddp",
    -- Folding
    ["<Tab>"] = "za",
    -- Buffer switching
    ["<leader>b"] = ":buffer ",
    -- Searching
    ["<leader>sg"] = function()
        local target = vim.fn.input("Global Search: ")
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

user.option.g = {
    mapleader = " ",
}

-- ----------------------------------------------------------------------------

return function()
    -- ------------------------------------------------------------------------
    -- Common mapping

    for mode, map_tbl in pairs(common_keymap) do
        for from, to in pairs(map_tbl) do
            map(mode, from, to)
        end
    end

    -- ------------------------------------------------------------------------
    -- Build System

    -- vimtex
    register_build_mapping("tex", "<cmd>w<cr><cmd>VimtexCompile<cr>")

    -- VOom
    register_build_mapping({ "markdown", "markdown.*" }, "<cmd>Voom markdown<cr>")
    register_build_mapping("html", "<cmd>Voom html<cr>")
    register_build_mapping("voomtree", "<cmd>VoomToggle<cr>")

    -- ------------------------------------------------------------------------
    -- nvim-tree

    nmap("<space>sb", "<cmd>NvimTreeToggle<cr>")
    nmap("<leader>tr", "<cmd>NvimTreeRefresh<cr>")
    nmap("<leader>tf", "<cmd>NvimTreeFindFile<cr>")

    -- ------------------------------------------------------------------------
    -- nvim-ufo

    local ufo = require "ufo"
    nmap("zR", ufo.openAllFolds)
    nmap("zM", ufo.closeAllFolds)

    -- ------------------------------------------------------------------------
    -- Floaterm

    for _, mode in ipairs { "n", "i", "t", "v" } do
        map(mode, "<F12>", "<cmd>FloatermToggle<cr>")
    end

    -- ------------------------------------------------------------------------
    -- Telescope

    nmap("<leader>f", "<cmd>Telescope find_files<cr>")
    nmap("<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>")

    -- ------------------------------------------------------------------------
    -- TSTree

    -- playground
    imap("<A-t>", "<cmd>TSPlaygroundToggle<cr>")
    nmap("<A-t>", "<cmd>TSPlaygroundToggle<cr>")
end
