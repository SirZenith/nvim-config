local log_util = require "user.util.log"

local api = vim.api

local BUILD_SYSTEM_AUGROUP = api.nvim_create_augroup("user.keybinding.build_system", { clear = true })

---@param filetype string|string[]
---@param mapto string|function
local function register_build_mapping(filetype, mapto)
    api.nvim_create_autocmd("FileType", {
        group = BUILD_SYSTEM_AUGROUP,
        pattern = filetype,
        callback = function()
            vim.keymap.set("n", "<A-b>", mapto, { buffer = true })
        end
    })
end

-- Lua File
register_build_mapping("lua", function()
    vim.ui.input({ prompt = "Run script in NeoVim? (Y/N) " }, function(input)
        if not input then return end

        if vim.bo.buftype ~= "" then
            log_util.info("Lau build only works on normal buffer")
            return
        end

        if input:lower() ~= "y" then
            log_util.info("execution interrupted.")
            return
        end

        local filename = vim.api.nvim_buf_get_name(0)
        if vim.fn.filereadable(filename) == 0 then
            log_util.info("file of current buffer not found")
            return
        end

        local chunk = loadfile(filename)
        if not chunk then
            log_util.info("failed to load file")
            return
        end

        xpcall(chunk, function(err)
            log_util.error(err)
        end)
    end)
end)

-- vimtex
register_build_mapping("tex", "<cmd>w<cr><cmd>VimtexCompile<cr>")

-- SymbolsOutline
register_build_mapping({ "html", "markdown", "markdown.*" }, "<cmd>SymbolsOutlineOpen<cr>")
register_build_mapping("Outline", "<cmd>SymbolsOutlineClose<cr>")
