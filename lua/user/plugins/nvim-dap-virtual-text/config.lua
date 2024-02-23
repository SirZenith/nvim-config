local user = require "user"

-- https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
---@class user.plugin.DapVariable
---@field name string
---@field value string # pssiblely multi-line text variable value representation.
---@field type? string # type name.
---@field presentationHint? table # of type VariablePresentationHint, meta info for UI rendering.
---@field evaluateName? string # name used in call to `evaluate` when try to fetch variable's value.
---@field variablesReference number
---@field namedVariables? number # number of named child variables.
---@field indexedVariables? number # number of inddexed child variables
---@field memoryReference? string # member reference associated with this variable.

-- https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
---@class user.plugin.DapStackFrame
---@field id number
---@field name string # The name of the stack frame, typically a method name.
---@field source? any # of type Source
---@field line number # The line withing the source of the frame.
---@field column number # Start position of the range covered by the stack frame.
---@field endLine? number
---@field endColumn? number
---@field canRestart? boolean # Indicates whether this frame can be restarted with the `restart` request.
---@field instructionPointerReference? string # A memory reference for the current instruction pointer in this frame.
---@field moduleId? number | string # The module associated with this frame, if any.
---@field presentationHint? "normal" | "label" | "subtle" # A hint for how to present this frame in the UI.

---@alias user.plugin.DapVirtualTextOptions table<string, any>

user.plugin.nvim_dap_virtual_text = {
    __newentry = true,
    -- enable this plugin (the default)
    enabled = true,
    -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
    enabled_commands = true,
    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
    highlight_changed_variables = true,
    -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
    highlight_new_as_changed = false,
    -- show stop reason when stopped for exceptions
    show_stop_reason = true,
    -- prefix virtual text with comment string
    commented = false,
    -- only show virtual text at first definition (if there are multiple)
    only_first_definition = true,
    -- show virtual text on all all references of the variable (not only definitions)
    all_references = false,
    -- clear virtual text on "continue" (might cause flickering when stepping)
    clear_on_continue = false,

    --- A callback that determines how a variable is displayed or whether it should be omitted
    --- @param variable user.plugin.DapVariable
    --- @param buf number
    --- @param stackframe user.plugin.DapStackFrame
    --- @param node TSNode
    --- @param options user.plugin.DapVirtualTextOptions # Current options for nvim-dap-virtual-text
    --- @return string? # A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
    display_callback = function(variable, buf, stackframe, node, options)
        if options.virt_text_pos == "inline" then
            return " = " .. variable.value
        else
            return variable.name .. " = " .. variable.value
        end
    end,

    -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
    virt_text_pos = vim.fn.has "nvim-0.10" == 1 and "inline" or "eol",

    -- experimental features:

    -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
    all_frames = false,
    -- show virtual lines instead of virtual text (will flicker!)
    virt_lines = false,
    -- position the virtual text at a fixed window column (starting from the first text column) ,
    -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
    virt_text_win_col = nil
}

return user.plugin.nvim_dap_virtual_text:with_wrap(function(value)
    require "nvim-dap-virtual-text".setup(value)
end)
