local user = require "user"
local utils = require "user.utils"
local fs = require "user.utils.fs"

local import = utils.import

local mark = user.env.PLATFORM_MARK()
local platform_config = mark
    and fs.path_join(
        user.env.USER_RUNTIME_PATH(), "user", "config", "platforms", mark
    )
    or ""
local augroup_id = vim.api.nvim_create_augroup("user.platform", { clear = true })

user.platform = {
    __new_entry = true,
    im_select = {
        check = "",
        on = "",
        off = "",
        isoff = function() return true end
    },
}

---@param augroup any
---@param cmd { check: string, on: string, off: string, isoff: fun(im: string): boolean }
local function im_auto_toggle_setup(augroup, cmd)
    if not cmd then return end

    local im_check_cmd = cmd.check or ""
    local im_on_cmd = cmd.on or ""
    local im_off_cmd = cmd.off or ""
    local im_isoff = cmd.isoff

    if im_check_cmd == ""
        or im_on_cmd == ""
        or im_off_cmd == ""
        or not im_isoff
    then
        return
    end

    local method_toggled = false
    local auto_toggle_on = true

    -- IM off
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = augroup,
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
        group = augroup,
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

local function base_finalize()
    im_auto_toggle_setup(augroup_id, user.platform.im_select())
end

-- ----------------------------------------------------------------------------

return function()
    local module = import(platform_config, "")
    base_finalize()
    utils.finalize_module(module)
end
