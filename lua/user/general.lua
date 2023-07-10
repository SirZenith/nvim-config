local user = require "user"

local augroup_id = vim.api.nvim_create_augroup("user.general", { clear = true })

local function im_auto_toggle_setup(cmd)
    if not cmd then
        return
    end

    local im_check_cmd = cmd.check

    local im_on_cmd = cmd.on
    local im_off_cmd = cmd.off
    local im_isoff = cmd.isoff

    local method_toggled = false
    local auto_toggle_on = true

    -- IM off
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = augroup_id,
        pattern = "*",
        callback = function()
            if not auto_toggle_on then return end

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
        group = augroup_id,
        pattern = "*",
        callback = function()
            if not auto_toggle_on then return end

            if method_toggled then
                vim.fn.system(im_on_cmd)
                method_toggled = false
            end
        end,
    })

    vim.api.nvim_create_user_command(
        "IMToggleOn",
        function() auto_toggle_on = true end,
        { desc = "turn on input method auto toggle" }
    )

    vim.api.nvim_create_user_command(
        "IMToggleOff",
        function() auto_toggle_on = false end,
        { desc = "turn off input method auto toggle" }
    )
end

-- ----------------------------------------------------------------------------

user.option = {
    o = {
        autochdir = false,              -- auto chdir into directory of current buffer
        autoread = true,                -- reload when file changed externally
        backspace = "indent,start,eol", -- select which boundary is ignored by backspace
        clipboard = "unnamedplus",      -- use system clipboard for yard
        splitbelow = true,              -- split at bottom when making horizontal split
        splitright = true,              -- split at right when making vertical split
        timeoutlen = 250,               -- set timeout for keymap
        fileformats = "unix,dos",
        -- file encoding checking queue
        fileencodings = "utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936",
        -- Indent
        tabstop = 4,
        softtabstop = 4,
        shiftwidth = 4,
        expandtab = true,
        autoindent = true,
        cindent = true,
        -- Folding
        -- foldmethod = "expr",
        -- foldexpr = "nvim_treesitter#foldexpr()",
        foldenable = true,
        foldnestmax = 4,
        -- set behaviour when buffer becomes invisible
        -- if `false` buffer will be set to inactive, else buffer will be set hidden
        hidden = true,
        -- search case sensitively only when pattern contains capital letter
        ignorecase = true,
        smartcase = true,
        completeopt = "menu,menuone,noselect",
        mouse = "a",
        grepprg = "rg --vimgrep",
        ruler = true,         -- show line:column coordinate in status line
        showcmd = true,       -- display command input
        showmatch = true,     -- show matching bracket
        scrolloff = 15,       -- key certain line gap between screen bottom
        termguicolors = true, -- turn true color support
        -- line number
        number = true,
        relativenumber = true,
        -- displaying special characters
        list = true,
        listchars = "tab:▸ ,trail:·,precedes:←,extends:→",
        -- line wrap
        wrap = false,
        textwidth = 0,
        wrapmargin = 0,
        -- when line wrap is off, key certain column gap between screen boundary,
        -- when this value is sufficently large, cursor will stay centered on screen
        sidescrolloff = 15,
        -- highlight cursor line
        cursorline = true,
        -- vertical ruler
        colorcolumn = "80",
        -- character concealing
        conceallevel = 1,
        -- concealcursor = "n", -- in these mode, also conceals cursorline

        -- setup LSP display
        cmdheight = 2,    -- height for command display area
        updatetime = 300, -- after certain timeout in millisecond, swap file will be written to disk
        -- display debug/diagnostic symbol in gutter
        -- `number` means share space with line number, don't create extra column
        signcolumn = "number",
    },
    go = {
        shell = "nu",
        shellcmdflag = "-c",
        shellquote = "",
        shellxquote = "",
        shellpipe = "| save --raw",
        shellredir = "| sed 's/\\033\\[[0-9;]*m//g' | save --raw",
    },
    g = {
        python3_host_prog = vim.env.PYTHON_PATH,
        loaded_netrwPlugin = 1, -- 禁用 Netrw
    }
}

user.general = {
    locale = "zh_CN.UTF-8",
    filetype = {
        -- 不使用软 tab 的类型
        no_soft_tab = { "go", "make", "plantuml", "vlang" },
        -- 文件类型对的文件名模式
        mapping = {
            json = { "*.meta" },
            nu = { "*.nu" },
            vlang = { "*.v", "*.vsh" },
            xml = { "*.xaml" },
        },
    },
    im_select = {
        check = "",
        on = "",
        off = "",
        isoff = function() return true end
    },
}

user.theme.highlight = {
    __new_entry = true,
    CursorLine = {
        fg = nil,
        bg = "#353c4a",
    },
    DiffChange = {
        bg = "#3a4657",
        fg = "#ebcb8b",
    },
    DiffCommon = {
        fg = "#808080"
    },
    DiffDelete = {
        bg = "#3a4657",
        fg = "#bf616a",
    },
    DiffInsert = {
        bg = "#3a4657",
        fg = "#a3be8c",
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
    PanelpalSelect = {
        fg = "#ebcb8b",
    },
    PanelpalUnselect = {
        fg = "#4f6074",
    },
    Visual = {
        fg = nil,
        bg = "#3a4657",
    },
}

-- ----------------------------------------------------------------------------

return function()
    vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1

    vim.cmd "filetype plugin indent on"

    im_auto_toggle_setup(user.general.im_select())

    local locale = user.general.locale()
    if locale then
        vim.cmd("language " .. locale)
    end

    local colorscheme = user.theme.colorscheme()
    if colorscheme and colorscheme ~= "" then
        vim.cmd("colorscheme " .. colorscheme)
    end

    for group, config in user.theme.highlight:pairs() do
        vim.api.nvim_set_hl(0, group, config)
    end

    -- disable all auto commenting.
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup_id,
        callback = function()
            vim.opt_local.formatoptions:remove { "c", "r", "o" }
        end,
    })

    -- filetype mapping
    for filetype, pattern in user.general.filetype.mapping:pairs() do
        vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
            group = augroup_id,
            pattern = pattern,
            callback = function() vim.opt_local.filetype = filetype end,
        })
    end

    -- setup filetypes that don't use soft-tab
    local no_soft_tab_filetypes = user.general.filetype.no_soft_tab()
    if no_soft_tab_filetypes then
        vim.api.nvim_create_autocmd("FileType", {
            group = augroup_id,
            pattern = no_soft_tab_filetypes,
            callback = function() vim.opt_local.expandtab = false end
        })
    end
end
