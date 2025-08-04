local user = require "user"
local util = require "user.util"

user.plugin.nvim_treesitter = {
    __newentry = true,
    install = {
        "bash",
        "bibtex",
        "c",
        "clojure",
        "cmake",
        -- "comment", -- disable due to performance problem
        "cpp",
        "c_sharp",
        "css",
        -- "dap_repl",
        "devicetree",
        "dot",
        "gitignore",
        "gleam",
        "glsl",
        "go",
        "gomod",
        "haskell",
        "html",
        "hyprlang",
        "ini",
        "javascript",
        "json",
        "kotlin",
        "latex",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "python",
        "qmljs",
        "query",
        "rasi",
        "regex",
        "ron",
        "rust",
        "scss",
        "sql",
        "toml",
        "typescript",
        "v",
        "vim",
        "vimdoc",
        "yaml",
        "yuck", -- configuration language for eww
        "zig",
    },
    parsers = {},
    filetype_setup = {
        markdown = function()
            -- remove italic in markdown code block
            local name = "MarkdownText"
            vim.api.nvim_set_hl(0, name, {})
            vim.api.nvim_set_hl(0, "@text.literal", { link = name })
        end,
    },
}

return user.plugin.nvim_treesitter:with_wrap(function(value)
    local nts = require "nvim-treesitter"
    local nts_parsers = require "nvim-treesitter.parsers"

    -- ------------------------------------------------------------------------

    for name, info in pairs(value.parsers) do
        -- vim.treesitter.language.register(<parser name>, <file type list>)
        nts_parsers[name] = info
    end

    -- ------------------------------------------------------------------------

    nts.install(value.install);

    -- ------------------------------------------------------------------------

    local filetype_set = {}
    for _, name in ipairs(value.install) do
        local info = nts_parsers[name]
        local target = info.filetype
        local target_t = type(target)

        if target == nil then
            -- target
        elseif target_t == "string" then
            filetype_set[target] = true
        elseif target_t == "table" then
            for _, t in ipairs(target) do
                filetype_set[t] = true
            end
        end
    end

    local filetype_list = {}
    for _, target in ipairs(filetype_set) do
        table.insert(filetype_list, target)
    end

    local augroup = vim.api.nvim_create_augroup("user.plugin.nvim_treesitter", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = filetype_list,
        callback = function(args)
            local uv = vim.uv

            -- load parser for files with relatively small size
            util.do_async_steps({
                function(next_step)
                    local filename = vim.api.nvim_buf_get_name(args.buf)
                    print(filename)
                    if filename == "" then
                        next_step(err, 0)
                    else
                        uv.fs_open(filename, "r", 438, next_step)
                    end
                end,
                function(next_step, err, fd)
                    if err then
                        next_step(err, nil)
                        return
                    end

                    if fd > 0 then
                        vim.uv.fs_fstat(fd, next_step)
                    else
                        next_step(nil, nil)
                    end
                end,
                function(next_step, err, stat)
                    if err then
                        return
                    elseif stat and stat.size > 20000 then
                        return
                    end

                    vim.schedule(next_step)
                end,
                function()
                    vim.treesitter.start()

                    local setup = user.plugin.nvim_treesitter.filetype_setup[args.match];
                    if type(setup) == "function" then
                        setup()
                    end
                end,
            })
        end,
    })
end)
