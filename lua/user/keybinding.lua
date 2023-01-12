local user = require "user"
local functional = require "user.utils.functional"
local ui = require "user.utils.ui"

local USER_TERMINAL_PANEL_BUF_NAME = "user.terminal"
---@type table<string, string>
local GLOBAL_SERACH_CMD_MAP = {
    default = [[:grep! '%s' '%s']],
}

local KEYBINDING_AUGROUP = vim.api.nvim_create_augroup("user.keybinding", { clear = true })

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
        ui.list_visible_buf(0),
        function(_, buf) return vim.bo[buf].filetype == "qf" end
    )
    vim.cmd(is_visible and "cclose" or "copen")
end

local function toggle_terminal()
    local name = USER_TERMINAL_PANEL_BUF_NAME
    local buf_num, win_num = ui.find_buf_with_name(name)

    if not buf_num then
        -- 不存在
        vim.cmd("vsplit | terminal")
        vim.cmd("keepalt file " .. name)
        vim.cmd "startinsert"
    elseif not win_num then
        -- 不可见
        vim.cmd("vsplit")
        local win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(win, buf_num)
        vim.cmd "startinsert"
    else
        vim.api.nvim_win_hide(win_num)
    end
end

---@param is_open_in_new_tab boolean
local function goto_cursor_file(is_open_in_new_tab)
    ---@type string[]
    local patterns = vim.split("?;?.lua;?.h;?.hpp", ";")
    local cfile = vim.fn.expand "<cfile>"

    local path
    for i = 1, #patterns do
        local p = patterns[i]:gsub("%?", cfile)
        if vim.fn.filereadable(p) == 1 then
            path = p
            break
        end
    end

    if not path then
        vim.notify("no match found for: " .. cfile)
    else
        local prefix = is_open_in_new_tab
            and "tabe "
            or "e "
        vim.cmd(prefix .. path)
    end
end

---@param target string
local function global_search(target)
    local template = GLOBAL_SERACH_CMD_MAP[vim.env.PLATFORM_MARK] or GLOBAL_SERACH_CMD_MAP.default
    local cmd = template:format(target, vim.fn.getcwd())
    vim.api.nvim_command(cmd)
    vim.api.nvim_command("cw")
end

---@param filetype string|string[]
---@param mapto string|function
local function register_build_mapping(filetype, mapto)
    vim.api.nvim_create_autocmd("FileType", {
        group = KEYBINDING_AUGROUP,
        pattern = filetype,
        callback = function()
            nmap("<A-b>", mapto, { buffer = true })
        end
    })
end

user.g.mapleader = " "

---@alias KeyMap {[string]: string|function}

---@type KeyMap
local n_common_keymap = {
    -- 标签管理
    -- 新标签
    ["<C-n>"] = "<cmd>tabnew<cr>",
    -- 关闭标签
    ["<A-w>"] = function()
        local cur_file = vim.expand("%:p")
        if vim.fn.filewritable(cur_file) then
            vim.cmd "w"
        end

        vim.cmd "close"
    end,

    -- 编辑相关
    ["<C-s>"] = "<cmd>w<cr>",
    ["dal"] = "0d$",
    [";;"] = "<esc>A;<esc>",
    [",,"] = "<esc>A,<esc>",
    ["<A-up>"] = "ddkP",
    ["<A-down>"] = "ddp",

    -- 用于控制折叠的开闭
    ["<Tab>"] = "za",

    -- Buffer 切换
    ["<leader>b"] = ":buffer ",

    -- 搜索
    ["<leader>sg"] = function()
        local target = vim.fn.input("Global Search: ")
        if not target or #target == 0 then return end
        global_search(target)
    end,

    -- 窗口分割移动
    ["<A-C-h>"] = "<C-w>H",
    ["<A-C-J>"] = "<C-w>J",
    ["<A-C-K>"] = "<C-w>K",
    ["<A-C-L>"] = "<C-w>L",

    -- 面板 toggle
    -- Quickfix 窗口
    ["<leader><backspace>"] = toggle_quickfix,
    -- 终端面板
    ["<C-p>"] = toggle_terminal,

    -- 移动
    -- 窗口分割间移动
    ["<leader>n"] = "<C-w>h",
    ["<leader>."] = "<C-w>l",
    -- 标签切换
    ["<leader>y"] = "gT",
    ["<leader>o"] = "gt",
    -- 行移动
    ["<leader>h"] = "^",
    ["<leader>l"] = "$",
    ["<leader>j"] = "+",
    ["<leader>k"] = "-",

    -- 跳转
    -- 历史位置跳转
    ["<C-h>"] = "<C-o>",
    ["<C-l>"] = "<C-i>",
    -- Quick Fix 跳转
    ["<A-j>"] = "<cmd>cnext<cr>",
    ["<A-k>"] = "<cmd>cprevious<cr>",
    -- 文件跳转
    ["gf"] = function() goto_cursor_file(false) end,
    ["<C-w>gf"] = function() goto_cursor_file(true) end,
}

---@type KeyMap
local i_common_keymap = {
    ["<C-y>"] = "<esc>",

    -- 编辑相关
    ["<C-s>"] = "<esc><cmd>w<cr>",
}

---@type KeyMap
local v_common_keymap = {
    ["<C-y>"] = "<esc>",

    -- 移动
    ["<leader>h"] = "^",
    ["<leader>l"] = "$",
    ["<leader>j"] = "+",
    ["<leader>k"] = "-",

    -- 搜索
    ["<leader>sg"] = function()
        local target = ui.visual_selection_text()
        if not target or #target == 0 then return end
        global_search(target)
    end,
}

---@type KeyMap
local t_common_keymap = {
    ["<C-y>"] = "<C-\\><C-n>",

    -- 终端面板
    ["<C-p>"] = toggle_terminal,
}

---@type KeyMap
local c_common_keymap = {
    ["<C-y>"] = "<esc>",

    -- 命令历史
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

-- -----------------------------------------------------------------------------

return function()
    -- -------------------------------------------------------------------------
    -- 常规映射

    for mode, map_tbl in pairs(common_keymap) do
        for from, to in pairs(map_tbl) do
            map(mode, from, to)
        end
    end

    -- -----------------------------------------------------------------------------
    -- Build System

    -- vimtex
    register_build_mapping("tex", "<cmd>w<cr><cmd>VimtexCompile<cr>")

    -- VOom
    register_build_mapping({ "markdown", "markdown.*" }, "<cmd>Voom markdown<cr>")
    register_build_mapping("html", "<cmd>Voom html<cr>")
    register_build_mapping("voomtree", "<cmd>VoomToggle<cr>")

    -- -----------------------------------------------------------------------------
    -- nvim-tree

    nmap("<space>sb", "<cmd>NvimTreeToggle<cr>")
    nmap("<leader>tr", "<cmd>NvimTreeRefresh<cr>")
    nmap("<leader>tf", "<cmd>NvimTreeFindFile<cr>")

    -- -----------------------------------------------------------------------------
    -- nvim-ufo

    local ufo = require "ufo"
    nmap("zR", ufo.openAllFolds)
    nmap("zM", ufo.closeAllFolds)

    -- -----------------------------------------------------------------------------
    -- Floaterm

    for _, mode in ipairs { "n", "i", "t", "v" } do
        map(mode, "<F12>", "<cmd>FloatermToggle<cr>")
    end

    -- -----------------------------------------------------------------------------
    -- Telescope

    nmap("<leader>f", "<cmd>Telescope find_files<cr>")
    nmap("<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>")

    -- -----------------------------------------------------------------------------
    -- TSTree

    -- playground
    imap("<A-t>", "<cmd>TSPlaygroundToggle<cr>")
    nmap("<A-t>", "<cmd>TSPlaygroundToggle<cr>")
end
