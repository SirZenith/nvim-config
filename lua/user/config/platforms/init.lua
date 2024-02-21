local user = require "user"
local util = require "user.util"
local fs_util = require "user.util.fs"

local import = util.import

---@class user.platform.ImSelectInfo
---@field check string
---@field on string
---@field off string
---@field isoff fun(im: string): boolean
--
---@field ignore_comment_filetype string[]
---@field should_reactivate fun(): boolean

local mark = user.env.PLATFORM_MARK()
local platform_config = mark
    and fs_util.path_join(
        user.env.USER_RUNTIME_PATH(), "user", "config", "platforms", mark
    )
    or ""
local augroup_id = vim.api.nvim_create_augroup("user.platform", { clear = true })

user.platform = {
    __new_entry = true,

    ---@type user.platform.ImSelectInfo
    im_select = {
        check = "",
        on = "",
        off = "",
        isoff = function() return true end,

        ignore_comment_filetype = {
            "",
            "html",
            "markdown",
            "help",
            "text",
        },
        should_reactivate = function()
            -- reactivate IM only in comment node.

            local cur_ft = vim.bo.filetype
            for _, ft in user.platform.im_select.ignore_comment_filetype:ipairs() do
                if ft == cur_ft then
                    return true
                end
            end

            local parser = vim.treesitter.get_parser()
            if not parser then
                return true
            end

            local tree = parser:parse()[1]
            if not tree then
                return true
            end

            local root = tree:root()

            local pos = vim.api.nvim_win_get_cursor(0)
            local row, col = pos[1] - 1, pos[2] - 1
            local node = root:named_descendant_for_range(row, col, row, col + 1)
            if not node then
                return true
            end

            local comment_found = false
            local walker = node
            while walker do
                if walker:type() == "comment" then
                    comment_found = true
                    break
                end
                walker = walker:parent()
            end

            return comment_found
        end,
    },
}

---@param augroup any
---@param cmd user.platform.ImSelectInfo
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

    local should_reactivate = cmd.should_reactivate

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
            end
        end,
    })

    -- IM on
    vim.api.nvim_create_autocmd("InsertEnter", {
        group = augroup,
        pattern = "*",
        callback = function()
            if not auto_toggle_on then return end

            if method_toggled and should_reactivate() then
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
    util.finalize_module(module)
end
