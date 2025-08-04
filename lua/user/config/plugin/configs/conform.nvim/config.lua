local user = require "user"

local formatter = require "user/config/plugin/configs/conform.nvim/formatter"
local filetype_map = require "user/config/plugin/configs/conform.nvim/filetype_map"

---@alias user.plugin.FormatterList (string | string[])[]
---@alias user.plugin.FormatterGetter fun(bufnr: integer): user.plugin.FormatterList
---@alias user.plugin.FormatterFileTypeMap table<string, user.plugin.FormatterList | user.plugin.FormatterGetter>

---@alias user.plugin.conform.lspFormatOpts
---| "never"
---| "fallback"
---| "prefer"
---| "first"
---| "last"

---@class user.plugin.DefaultFormattingArgs
---@field timeout_ms? integer
---@field lsp_format? user.plugin.conform.lspFormatOpts
---@field quiet? boolean
---@field stop_after_first? boolean

---@class user.plugin.FormattingArgs : user.plugin.DefaultFormattingArgs
---@field bufnr? integer
---@field async? boolean
---@field dry_run? boolean
---@field formatters? string[]
---@field range? table
--
---@field id? integer # get passed to vim.lsp.buf.format when needed
---@field name? string # get passed to vim.lsp.buf_format when needed
---@field filter? fun(client: lsp.Client): boolean # get passed to vim.lsp.buf_format when needed
--
---@field callback? fun(err?: string, did_edit?: boolean)

---@class user.plugin.FormatterInfo
---@field command string
---@field args? string[] | fun(self: user.plugin.FormatterInfo, ctx: table): string | string[]
---@field range_args? fun(ctx: table): string[]
---@field stdin? boolean # send file content to stdin, read output from stdout, default true
---@field cwd? string
---@field require_cmd? boolean # mark formatter as unavailabel when cwd does not found, default false
---@field exit_codes? integer[] # exit codes indicating success, default `{ 0 }`
---@field env? table<string, any>
---@field inherit? boolean # merge with built-in config instead of overriding, default true
---@field prepend_args? string[] # arguments to be prepend to argument list.

user.plugin.conform_nvim = {
    __newentry = true,

    ---@type table<string, user.plugin.FormatterInfo | fun(bufnr: integer): user.plugin.FormatterInfo>
    formatters = formatter,

    -- Multiple formatters will be called sequentially.
    -- For formatters in nested list, only first available one will be used.
    -- Special filetypes:
    -- - `*`: all file type.
    -- - `_`: default formatter for files with no available formatter.
    formatters_by_ft = filetype_map,

    -- default argument used when call `format()`
    default_format_opts = {
        lsp_format = "first",
    },

    -- Argument used for `format()` call on save
    ---@type user.plugin.FormattingArgs?
    format_on_save = {
        timeout_ms = 500,
        lsp_format = "first",
    },

    -- Argument used for `format()` call after save
    ---@type user.plugin.FormattingArgs?
    format_after_save = {
        lsp_format = "first",
    },

    -- Log level form `:ConformInfo`
    ---@type integer
    log_level = vim.log.levels.WARN,

    ---@type boolean
    notify_on_error = true,
    ---@type boolean
    notify_no_formatters = true,
}

return user.plugin.conform_nvim:with_wrap(function(value)
    require "conform".setup(value)
end)
