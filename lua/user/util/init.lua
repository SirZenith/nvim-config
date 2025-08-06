local log_util = require "user.util.log"

local api = vim.api
---@module "uv"
local uv = vim.uv
local hrtime = uv.hrtime

local M = {}

-- ----------------------------------------------------------------------------

-- wrap_selected_text_with adds given content to the left and right side of selected
-- part of buffer text.
---@param left string
---@param right string
function M.wrap_selected_text_with(left, right)
    local panelpal = require "panelpal"

    local st_r, st_c, ed_r, ed_c = panelpal.visual_selection_range()
    if not (st_r and st_c and ed_r and ed_c) then return end

    local bufnr = 0

    local ed_line = api.nvim_buf_get_lines(bufnr, ed_r, ed_r + 1, true)[1]
    if not ed_line then return end

    local ed_offset = ed_c + vim.str_utf_end(ed_line, ed_c)

    local list = api.nvim_buf_get_text(bufnr, st_r, st_c, ed_r, ed_offset, {})
    local len = #list
    if len == 0 then return end

    list[1] = left .. list[1]
    list[len] = list[len] .. right

    for _, line in ipairs(list) do
        print(line)
    end

    api.nvim_buf_set_text(0, st_r, st_c, ed_r, ed_offset, list)
end

-- ----------------------------------------------------------------------------

---@param err string
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
    local ok, result = xpcall(require, on_import_error, modname)

    if not ok then
        log_util.warn("failed to load module:", modname)
        if not failed_msg then
            log_util.warn(result)
        elseif failed_msg ~= "" then
            log_util.warn(failed_msg)
        end
        return nil
    end

    return result
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
---@return boolean
function M.finalize_module(module)
    local module_type = type(module)

    local final
    if module_type == "function" then
        final = module
    elseif module_type == "table" then
        final = module.finalize
    end

    local ok = true
    if type(final) == "function" then
        ok = xpcall(final, on_import_error)
    end

    return ok
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

    local function finalize_one_module()
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

    local function next_step(...)
        index = index + 1
        local step = steps[index]
        if type(step) ~= "function" then
            return
        end

        step(next_step, ...)
    end

    next_step(...)
end

-- ----------------------------------------------------------------------------

---@param basename string
---@param src_dir string
---@param output_dir string
---@param on_finished fun(err: string?, updated: boolean?)
local function try_update_compiled_code(basename, src_dir, output_dir, on_finished)
    local src_file = vim.fs.joinpath(src_dir, basename)
    local output_file = vim.fs.joinpath(output_dir, basename .. "c")

    M.do_async_steps({
        function(next_step)
            uv.fs_stat(src_file, next_step)
        end,

        ---@param err string?
        ---@param fd integer?
        function(next_step, err, src_stat)
            if not src_stat or err then
                on_finished(src_file .. " stat failed: " .. err)
                return
            end

            if vim.fn.filereadable(output_file) == 0 then
                next_step()
                return
            end

            uv.fs_stat(output_file, function(stat_err, output_stat)
                if not output_stat or stat_err then
                    on_finished(output_file .. " stat failed: " .. stat_err)
                    return
                end

                local src_mtime = src_stat.mtime
                local out_mtime = output_stat.mtime
                local is_valid = out_mtime.sec > src_mtime.sec
                if is_valid and out_mtime.sec == src_mtime.sec then
                    is_valid = out_mtime.nsec > src_mtime.nsec
                end

                if is_valid then
                    on_finished()
                    return
                end

                next_step()
            end)
        end,

        function(next_step)
            uv.fs_open(output_file, "w+", 438, vim.schedule_wrap(next_step))
        end,

        ---@param err string?
        ---@param fd integer?
        function(next_step, err, fd)
            if not fd or err then
                on_finished("failed to open" .. output_file .. ": " .. err)
                return
            end

            local chunk, load_err = loadfile(src_file)
            if not chunk then
                on_finished("failed to load " .. src_file .. ": " .. load_err)
                return
            end

            local bytecode = string.dump(chunk, true)
            uv.fs_write(fd, bytecode)
            uv.fs_close(fd)

            on_finished(nil, true)
        end,
    })
end

---@param src_dir string
---@param output_dir string
---@param on_finished fun(err: string?)
local function compile_config_async(src_dir, output_dir, on_finished)
    local handle, scan_err = uv.fs_scandir(src_dir)
    if not handle then
        on_finished("failed to read directory " .. src_dir .. ": " .. scan_err)
        return
    end

    if vim.fn.isdirectory(output_dir) == 0 then
        uv.fs_mkdir(output_dir, 493)
    end

    local name ---@type string?
    local compile_dir ---@type fun(err: string?, updated: boolean?)
    compile_dir = vim.schedule_wrap(function(err, updated)
        if err then
            log_util.warn(err)
        end

        if updated then
            local msg = ("byte code updated: %s/%s"):format(src_dir, name)
            vim.notify(msg, vim.log.levels.INFO)
        end

        name = uv.fs_scandir_next(handle)
        if not name then
            on_finished()
            return
        end

        local path = vim.fs.joinpath(src_dir, name)

        if vim.fn.filereadable(path) == 1 then
            if name:sub(#name - 3, #name) == ".lua" then
                try_update_compiled_code(name, src_dir, output_dir, compile_dir)
            else
                compile_dir()
            end
        else
            local new_root = vim.fs.joinpath(src_dir, name)
            local new_out = vim.fs.joinpath(output_dir, name)
            compile_config_async(new_root, new_out, compile_dir)
        end
    end)

    compile_dir()
end

---@param src_dir string
---@param output_dir string
---@param options? { quiet: boolean }
function M.compile_config(src_dir, output_dir, options)
    compile_config_async(src_dir, output_dir, function(err)
        local is_quiet = options and options.quiet
        if not is_quiet then
            if err then
                log_util.warn(err)
            end
            vim.notify("Compilation complete", vim.log.levels.INFO)
        end
    end)
end

return M
