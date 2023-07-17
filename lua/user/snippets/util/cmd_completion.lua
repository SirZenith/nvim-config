local import = require "user.utils".import

local M = {}

local EMPTY_SIGNAL_ITEM = { ["[empty]"] = true }

---@alias CommandMap { [string]: CommandMap }

---@class CompletionItem
---@field label string
---@field dup number

M.name = "cmd-snip-cmp"

---@type string[]
M.trigger_characters = { ":", " " }

---@type CommandMap | nil
local cmd_map = nil

function M.set_cmd_map(map)
    cmd_map = map
end

-- ----------------------------------------------------------------------------

---@return string[]
function M:get_trigger_characters()
    return M.trigger_characters
end

function M:is_available()
    return cmd_map ~= nil
end

local function gen_completion(params)
    local items = {}
    if not cmd_map then return items end

    local line = params.context.cursor_before_line
    if not line then return items end

    local cmd = line:match(":(.*)$")
    if not cmd then return items end

    cmd = cmd:gsub("%s+", "\n") .. "\n"
    local segments = vim.split(cmd, "\n", { plain = true })
    for i = #segments, 1, -1 do
        if segments[i] == "" then
            table.remove(segments, i)
        end
    end

    local walker = cmd_map
    for _, seg in ipairs(segments) do
        walker = walker[seg]

        if type(walker) ~= "table" then
            walker = EMPTY_SIGNAL_ITEM
            break
        end
    end

    for k in pairs(walker) do
        table.insert(items, {
            label = k,
            dup = 0,
            kind = vim.lsp.protocol.CompletionItemKind.Method,
        })
    end

    return items
end

-- Completion only start on a line ends with pattern `%(%S*`.
---@param params any
---@param callback fun(result: { items: CompletionItem[], isIncomplete: boolean } | nil)
function M:complete(params, callback)
    if not cmd_map then
        callback(nil)
        return
    end

    local items = gen_completion(params)

    callback({ items = items, isIncomplete = false })
end

-- ----------------------------------------------------------------------------

function M.init()
    local cmp = import "cmp"
    if not cmp then return end

    cmp.register_source(M.name, M)
end

return M
