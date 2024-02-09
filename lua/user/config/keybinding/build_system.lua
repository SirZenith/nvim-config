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
            vim.notify("Lau build only works on normal buffer")
            return
        end

        if input:lower() ~= "y" then
            vim.notify("execution interrupted.")
            return
        end

        local filename = vim.api.nvim_buf_get_name(0)
        if vim.fn.filereadable(filename) == 0 then
            vim.notify("file of current buffer not found")
            return
        end

        local chunk = loadfile(filename)
        if not chunk then
            vim.notify("failed to load file")
            return
        end

        xpcall(chunk, function(err)
            vim.notify(err, vim.log.levels.ERROR)
        end)
    end)
end)

-- vimtex
register_build_mapping("tex", "<cmd>w<cr><cmd>VimtexCompile<cr>")

-- VOom
register_build_mapping({ "markdown", "markdown.*" }, "<cmd>Voom markdown<cr>")
register_build_mapping("html", "<cmd>Voom html<cr>")
register_build_mapping("voomtree", "<cmd>VoomToggle<cr>")
