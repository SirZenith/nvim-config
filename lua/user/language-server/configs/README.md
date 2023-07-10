This is a directory for placing custom config for each LSP server.

Each config file under this directory should be exactly named after its target
LSP server.

Return value of running those file should be a config table for nvim-lspconfig.

Such table should satisfy following interface:

```lua
---@class ConfigTbl
---@field cmd? string[] | fun() # list of string or Lua function to spawning LSP server.
---@field settings? table # user config which will be sent to LSP server as workspace setting.
---@field filetype string[] # automatically starts LSP server for listed filetypes.
---@field on_attach fun(client, bufr)
---@field on_new_config(new_config, root_dir: string)
---@field commands { [CommandName]: CommandDef } # crate user commands when LSP client is setup for buffer.

---@alias CommandName string

-- The first element of a command def should be callback function for this command.
--
-- All key-valuee pair in CommandDef will be used as `opts` parameter for
-- `vim.api.nvim_create_user_command`.
---@class CommandDef : table<string, string | boolean | number>
---@field [1] function
```
