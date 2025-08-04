local recording_reg = nil ---@type string?

local function update_recording_reg()
    local reg = vim.fn.reg_recording()
    if reg == "" then
        recording_reg = nil
    else
        recording_reg = "%#lualine_a_command#󰻃 " .. reg
    end
end

local augroup = vim.api.nvim_create_augroup("user.plugin.nvim_lualine.component_macro", { clear = true })

vim.api.nvim_create_autocmd("RecordingEnter", {
    group = augroup,
    callback = function()
        update_recording_reg()
    end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
    group = augroup,
    callback = function()
        recording_reg = nil
    end,
})

return function()
    return recording_reg or ''
end
