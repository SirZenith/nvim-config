local user = require "user"

local env_config = require "user.base.env"

user.option = {
    __newentry = true,

    o = {
        autochdir = false,              -- auto chdir into directory of current buffer
        autoread = true,                -- reload when file changed externally
        backspace = "indent,start,eol", -- select which boundary is ignored by backspace
        clipboard = "unnamedplus",      -- use system clipboard for yard
        splitbelow = true,              -- split at bottom when making horizontal split
        splitright = true,              -- split at right when making vertical split
        timeoutlen = 250,               -- set timeout for keymap
        fileformats = "unix,dos",
        fixendofline = false,           -- don't append new line at EOF
        -- file encoding checking queue
        fileencodings = "utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936",
        -- Indent
        tabstop = 4,
        softtabstop = 4,
        shiftwidth = 4,
        expandtab = true,
        autoindent = false,
        cindent = false,
        -- Folding
        foldmethod = "manual",
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
        mouse = "",
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
        shellpipe = "out>",
        shellredir = "out>",
    },
    g = {
        mapleader = " ",
        python3_host_prog = env_config.PYTHON_PATH,
    },
}

return function()
    for k, tbl in user.option:pairs() do
        local target = vim[k]
        for field, value in pairs(tbl) do
            target[field] = value
        end
    end
end
