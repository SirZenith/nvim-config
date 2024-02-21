local log_util = require "user.util.log"

local hrtime = vim.loop.hrtime

---@param s string
---@param prefix string
function string.starts_with(s, prefix)
    local l_suf = #prefix
    local l_s = #s
    if l_s < l_suf then
        return false
    end

    return string.sub(s, 1, l_suf) == prefix
end

---@param s string
---@param suffix string
function string.ends_with(s, suffix)
    local l_s = #s
    local l_suf = #suffix
    if l_s < l_suf then
        return false
    end

    return string.sub(s, l_s - l_suf + 1) == suffix
end

-- ----------------------------------------------------------------------------

local M = {}

-- ----------------------------------------------------------------------------

local special_camel_word = {
    ui = "UI",
    id = "ID",
}

---@param text string
---@return string
local function capital_fist_letter(text)
    if text == "" then return "" end
    return text:sub(1, 1):upper() .. text:sub(2)
end

---@param text string
---@return string
function M.underscore_to_camel_case(text)
    local st, buffer = 1, {}

    for i = 1, #text do
        if text:sub(i, i) == "_" then
            local part = text:sub(st, i - 1)
            local special = special_camel_word[part:lower()]
            buffer[#buffer + 1] = special or capital_fist_letter(part)
            st = i + 1
        end
    end

    buffer[#buffer + 1] = capital_fist_letter(text:sub(st, #text))

    return table.concat(buffer)
end

-- ----------------------------------------------------------------------------

---@param err? string
local function on_import_error(err)
    local thread = coroutine.running()
    local traceback = debug.traceback(thread, err)
    log_util.warn(traceback or err)
end

-- wrap require in xpcall, print traceback then return nil when failed.
---@param modname string
---@param failed_msg? string
---@return any?
function M.import(modname, failed_msg)
    local ret = { xpcall(require, on_import_error, modname) }
    local ok = ret[1]

    if not ok then
        log_util.warn("failed to load module:", modname)
        if not failed_msg then
            log_util.warn(tostring(ret[2]))
        elseif failed_msg ~= "" then
            log_util.warn(failed_msg)
        end
        return nil
    end

    return unpack(ret, 2)
end

-- Wrap the task_func with a new func, which when called tries to import target module
-- andcall task_func with that module.
-- If loading process successed, wrapper function returns true, else returns false.
---@param modname string
---@param task_func fun(m: any)
---@return fun(): boolean
function M.wrap_with_module(modname, task_func)
    return function()
        local module = M.import(modname, "")
        if not module then
            return false
        end

        task_func(module)

        return true
    end
end

-- Try to finalize a single module
---@param module any
function M.finalize_module(module)
    local module_type = type(module)

    local final
    if module_type == "function" then
        final = module
    elseif module_type == "table" then
        final = module.finalize
    end

    if type(final) == "function" then
        xpcall(final, on_import_error)
    end
end

-- Import a list of modules, import and finalize all of them. Each module can
-- return one of following values:
-- - nil
-- - fun()
-- - { finalize: fun() }
-- - { async: true, finalize: fun(callback: fun(finalizable?: fun() | { finalize: fun() }) }
---@param modules any[]
---@param callback fun()
function M.finalize_async(modules, callback)
    local i = 0

    local finalize_one_module
    finalize_one_module = function()
        i = i + 1
        local module = modules[i]
        if not module then
            callback()
            return
        end

        if type(module) ~= "table"
            or not module.async
            or type(module.finalize) ~= "function"
        then
            M.finalize_module(module)
            finalize_one_module()
            return
        end

        M.do_async_steps {
            function(next_step)
                local ok = xpcall(module.finalize, on_import_error, next_step)
                if not ok then
                    next_step()
                end
            end,
            function(_, target)
                M.finalize_module(target)
                finalize_one_module()
            end,
        }
    end

    finalize_one_module()
end

-- notify shows notifycation.
---@param msg string
---@param level? string | integer # vim.log.levels
---@param opt? table<string, any>
function M.notify(msg, level, opt)
    local notify = M.import "notify"
    if notify then
        notify(msg, level, opt)
    else
        vim.notify(msg)
    end
end

---@param msg string
---@param func function
---@param ... any
function M.execution_timing(msg, func, ...)
    local start_time = hrtime()
    func(...)
    local duration = hrtime() - start_time
    print(("%s: %.2fms"):format(msg, duration / 1e6))
end

---@alias user.util.AsyncStepFunc fun(next_step: fun(...), ...: any)

---@param steps user.util.AsyncStepFunc[]
---@param ... any
function M.do_async_steps(steps, ...)
    local index = 0

    local next_step
    next_step = function(...)
        index = index + 1
        local step = steps[index]
        if type(step) ~= "function" then
            return
        end

        step(next_step, ...)
    end

    next_step(...)
end

return M
