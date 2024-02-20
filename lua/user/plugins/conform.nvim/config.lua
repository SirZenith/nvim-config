local user = require "user"

---@alias user.plugin.FormatterList (string | string[])[]
---@alias user.plugin.FormatterGetter fun(bufnr: integer): user.plugin.FormatterList
---@alias user.plugin.FormatterFileTypeMap table<string, user.plugin.FormatterList | user.plugin.FormatterGetter>

---@class user.plugin.FormattingArgs
---@field timeout_ms? integer
---@field bufnr? integer
---@field async? boolean
---@field dry_run? boolean
---@field formatters? string[]
---@field lsp_fallback? boolean | "always"
---@field quiet? boolean
---@field range? table
--
---@field id? integer # get passed to vim.lsp.buf.format when needed
---@field name? string # get passed to vim.lsp.buf_format when needed
---@field filter? fun(client: lsp.Client): boolean # get passed to vim.lsp.buf_format when needed
--
---@field callback? fun(err?: string, did_edit?: boolean)

---@class user.plugin.FormatterInfo
---@field command string
---@field args? string[] | fun(): string | string[]
---@field range_args? fun(ctx: table): string[]
---@field stdin? boolean # send file content to stdin, read output from stdout, default true
---@field cwd? string
---@field require_cmd? boolean # mark formatter as unavailabel when cwd does not found, default false
---@field exit_codes? integer[] # exit codes indicating success, default `{ 0 }`
---@field env? table<string, any>
---@field inherit? boolean # merge with built-in config instead of overriding, default true
---@field prepend_args? string[] # arguments to be prepend to argument list.

user.plugin.conform_nvim = {
    __new_entry = true,

    ---@type table<string, user.plugin.FormatterInfo | fun(bufnr: integer): user.plugin.FormatterInfo>
    formatters = {
        ["prettier-eslint"] = {
            command = vim.fn.has("win32") == 1 and "prettier-eslint.cmd" or "prettier-eslint",
            args = { "--stdin", "--stdin-filepath", "$FILENAME" },
        },
        prettier_d_slim = {
            command = vim.fn.has("win32") == 1 and "prettier_d_slim.cmd" or "prettier_d_slim",
            args = { "--stdin", "--stdin-filepath", "$FILENAME" },
        },
    },

    -- Multiple formatters will be called sequentially.
    -- For formatters in nested list, only first available one will be used.
    -- Special filetypes:
    -- - `*`: all file type.
    -- - `_`: default formatter for files with no available formatter.
    ---@type user.plugin.FormatterFileTypeMap
    formatters_by_ft = {
        ["_"] = { "trim_whitespace" },
        javascript = { "prettier_d_slim", "eslint_d" },
        typescript = { "prettier_d_slim", "eslint_d" },
    },

    -- Argument used for `format()` call on save
    ---@typeuser.plugin.FormattingArgs?
    format_on_save = {
        -- I recommend these options. See :help conform.format for details.
        timeout_ms = 500,
        lsp_fallback = true,
    },

    -- Argument used for `format()` call after save
    ---@type user.plugin.FormattingArgs?
    format_after_save = nil,

    -- Log level form `:ConformInfo`
    ---@type integer
    log_level = vim.log.levels.WARN,

    ---@type boolean
    notify_on_error = true,
}

return function()
    require "conform".setup(user.plugin.conform_nvim())
end
