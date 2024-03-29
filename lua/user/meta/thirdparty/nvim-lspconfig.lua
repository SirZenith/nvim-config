---@meta

---@alias lspconfig.OnNewCfgFunc fun(new_config: lspconfig.ConfigTbl, new_root_dir: string)
---@alias lspconfig.Capabilities table<string, string | table | boolean | function>
---@alias lspconfig.InitOptions table<string, string | table | boolean>
---@alias lspconfig.Settings table<string, string | table | boolean>
---@alias lspconfig.CommandName string

-- The first element of a command def should be callback function for this command.
--
-- All key-value pair in CommandDef will be used as `opts` parameter for
-- `vim.api.nvim_create_user_command`.
---@class lspconfig.CommandDef : table<string, string | boolean | number>
---@field [1] function

---@class lspconfig.ConfigTbl
---@field name string
--
---@field root_dir fun(filename: string, bufnr: integer): string? # returns root directory of workspace. Only when actual path is returned, a new client will be created.
---@field single_file_support boolean # if true, server can be started without matching root directory.
--
---@field on_new_config lspconfig.OnNewCfgFunc # gets called after a root directory is detected before server is spawned. This funciton is mainly used to modified LSP config with root directory infomation, e.g. launch locally installed tsserver.
---@field on_attach fun(client: lsp.Client, bufnr: integer)
--
---@field filetypes? string[] # automatically starts LSP server for listed filetypes.
---@field autostart boolean # automatically starts server with FileType autocommand, if false, client should be launched by `:LspStart`
--
---@field cmd? string[] | fun() # list of string or Lua function to spawning LSP server.
---@field cpabilities lspconfig.Capabilities
---@field handlers table<string, function>
---@field init_options lspconfig.InitOptions # Param used during initialization notification.
---@field settings? lspconfig.Settings # LSP server workspace configuration table. Sent by workspace/didChangeConfiguration on client init.
