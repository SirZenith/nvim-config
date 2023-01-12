local user = require "user"
local utils = require "user.utils"

user.o = {
    autochdir = false, -- 总是自动切换到当前 buffer 所在的目录
    autoread = true, -- 文件被外部改动时自动刷新内容
    backspace = "indent,start,eol", -- 设定退格键可以跨越的界限
    clipboard = "unnamedplus", -- 使用系统剪贴板存放复制内容

    splitbelow = true, -- 横向切分创建在下方
    splitright = true, -- 纵向切分创建在右侧

    timeoutlen = 250, -- 设定组合键检测的超时

    -- 打开文件时自动逐个尝试编码，直到解码过程没有发生错误
    fileencodings = "utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936",

    -- 缩进设定
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    expandtab = true,
    autoindent = true,
    cindent = true,

    -- 折叠设定
    -- foldmethod = "expr",
    -- foldexpr = "nvim_treesitter#foldexpr()",
    foldenable = true,
    foldnestmax = 4,

    -- 设定 buffer 转为完全不可见时的行为，为 `false` 时，buffer 不可见时会被抛弃
    -- 此时 buffer 对应的编辑历史会被清空
    hidden = true,

    -- 搜索只在目标 pattern 包含大写时对大小写敏感
    ignorecase = true,
    smartcase = true,

    completeopt = "menu,menuone,noselect",
    mouse = "a",
    grepprg = "rg --vimgrep",

    ruler = true, -- 在状态栏显示光标所在坐标
    showcmd = true, -- 显示输入的命令
    showmatch = true, -- 显示括号匹配
    scrolloff= 15, -- 光标尽量和页码底部保持指定的行数间距
    termguicolors = true, -- 开启终端真色彩支持

    -- 行号
    number = true,
    relativenumber = false,

    -- 特殊字符转换显示
    list = true,
    listchars = "tab:▸ ,trail:·,precedes:←,extends:→",

    -- 自动折行
    wrap = false,
    textwidth = 0,
    wrapmargin = 0,
    -- 自动折行关闭时，光标横移时尽量和窗口边缘保持指定列数
    -- 此值充分大时，光标会尽量保持在屏幕中央
    sidescrolloff = 15,

    -- 光标所在行突出
    cursorline = true,

    -- 纵向标尺
    colorcolumn = "80",

    -- 内容隐藏
    conceallevel = 1,
    -- concealcursor = "n", -- 在指定的模式下，光标所在行的文字也隐藏

    -- 为 LSP 内容显示提供支持
    cmdheight = 2, -- 命令显示使用的行数
    updatetime = 300, -- 在指定毫秒后若没有文件内容变动，swap 文件就会定入硬盘
    -- 侧边 debug/诊断符号显示
    -- `number` 为不独立为符号添加侧边列，符号和行号共用位置
    signcolumn = "number",
}

user.go = {
    shell = "nu",
    shellcmdflag = "-c",
    shellquote = "",
    shellxquote = "",
    shellpipe = "| save --raw",
    shellredir = "| sed 's/\\033\\[[0-9;]*m//g' | save --raw",
}

user.g = {
    python3_host_prog = vim.env.PYTHON_PATH,
    loaded_netrwPlugin = 1, -- 禁用 Netrw
}

user.general = {
    -- locale = "zh_CN.UTF-8",
    filetype = {
        -- 不使用软 tab 的类型
        no_soft_tab = { "go", "make", "plantuml", "vlang" },
        -- 文件类型对的文件名模式
        mapping = {
            vlang = { "*.v", "*.vsh" },
        },
    },
}

user.theme.highlight = {
    CursorLine = {
        fg = nil,
        bg = "#353c4a",
    },
    Folded = {
        fg = "#7e828c",
        bg = "#282d38",
    },
    LspLogTrace = {
        bg = "#3e4a5b",
    },
    LspLogDebug = {
        bg = "#4f6074",
    },
    LspLogInfo = {
        fg = "#000000",
        bg = "#a3be8c",
    },
    LspLogWarn = {
        fg = "#000000",
        bg = "#ebcb8b",
    },
    LspLogError = {
        fg = "#ffffff",
        bg = "#bf616a",
    },
    Visual = {
        fg = nil,
        bg = "#3a4657",
    }
}

-- -----------------------------------------------------------------------------

return function()
    vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1

    local locale = user.general.locale()
    if locale then
        vim.cmd("language " .. locale)
    end
    vim.cmd("colorscheme " .. user.theme.colorscheme())

    vim.cmd "filetype plugin indent on"

    for group, config in user.theme.highlight:pairs() do
        vim.api.nvim_set_hl(0, group, config)
    end

    local augroup_id = vim.api.nvim_create_augroup("user.general", { clear = true })

    -- 禁用注释相关的自动格式化行为
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup_id,
        callback = function()
            vim.opt_local.formatoptions:remove { "c", "r", "o" }
        end,
    })

    -- 文件类型映射
    for filetype, pattern in user.general.filetype.mapping:pairs() do
        vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
            group = augroup_id,
            pattern = pattern,
            callback = function() vim.opt_local.filetype = filetype end,
        })
    end

    -- 不使用软 tab 的文件类型
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup_id,
        pattern = user.general.filetype.no_soft_tab(),
        callback = function() vim.opt_local.expandtab = false end
    })

    -- -------------------------------------------------------------------------
    -- 输入法自动切换

    ---@enum PlatformMark
    ---| "linux"
    ---| "termux"
    ---| "windows"
    ---| "wsl"
    ---| "wsl2"

    ---@class CommandSet
    ---@field check string
    ---@field on string
    ---@field off string
    ---@field isoff fun(im: string): boolean

    ---@type table<PlatformMark, CommandSet>
    local cmd_map = {}

    cmd_map.default = {
        check = "", on = "", off = "",
        isoff = function() return true end
    }

    cmd_map.linux = {
        check = "fcitx5-remote",
        on = "fcitx5-remote -o",
        off = "fcitx5-remote -c",
        isoff = function(im)
            return tonumber(im) == 1
        end
    }
    cmd_map.wsl = {
        check = "im-select.exe",
        on = "im-select.exe 2052",
        off = "im-select.exe 1033",
        isoff = function(im)
            return tonumber(im) == 1033
        end
    }
    cmd_map.wsl2 = cmd_map.wsl
    cmd_map.windows = cmd_map.wsl

    local mark = vim.env.PLATFORM_MARK ---@type PlatformMark
    local cmd = cmd_map[mark] or cmd_map.default
    local im_check_cmd = cmd.check
    local im_on_cmd = cmd.on
    local im_off_cmd = cmd.off
    local im_isoff = cmd.isoff

    local method_toggled = false

    if cmd_map[mark] then
        -- IM off
        vim.api.nvim_create_autocmd("InsertLeave", {
            pattern = "*",
            callback = function()
                local im = vim.fn.system(im_check_cmd)
                if not im_isoff(im) then
                    method_toggled = true
                    vim.fn.system(im_off_cmd)
                else
                    method_toggled = false
                end
            end,
        })

        -- IM on
        vim.api.nvim_create_autocmd("InsertEnter", {
            pattern = "*",
            callback = function()
                if method_toggled then
                    vim.fn.system(im_on_cmd)
                    method_toggled = false
                end
            end,
        })
    end
end
