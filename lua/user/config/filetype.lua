local user = require "user"
local fs_util = require "user.util.fs"
local functional_util = require "user.util.functional"

local augroup_id = vim.api.nvim_create_augroup("user.filetype", { clear = true })

user.filetype = {
    __newentry = true,

    -- disable soft tab for listed file types
    no_soft_tab = { "go", "make", "plantuml", "vlang" },

    filetype_indent = {
        gleam = 2,
    },

    -- file type mapping pattern. file types appear earlier in the list take
    -- high priority.
    -- `secondary = true` means that file type will be appended to original
    -- file type.
    mapping = {
        {
            name = "json",
            pattern = "%.meta$",
        },
        {
            name = "nu",
            override = true,
            pattern = "%.nu$",
        },
        {
            name = "v",
            pattern = { "%.v$", "%.vsh$", ".*/v.mod$" },
            override = true,
            condition = function(match)
                local ok = false

                for path in vim.fs.parents(match) do
                    local mod_file_path = fs_util.path_join(path, "v.mod")
                    ok = vim.fn.filereadable(mod_file_path) == 1
                    if ok then
                        break
                    end
                end

                return ok
            end,
        },
        {
            name = "xml",
            pattern = "%.xaml$",
        },
        {
            name = "snippet",
            pattern = "/snippets/.+%-load/.-%.lua$",
            secondary = true,
        },
        {
            name = "tree-sitter-test",
            pattern = {
                "tree%-sitter%-.-/corpus/.+%..*$",
                "tests%-for%-future/.+$",
            },
            secondary = true,
        },
        {
            name = "plantuml",
            pattern = "%.puml$",
        },
        {
            name = "qmljs",
            pattern = "%.qml$",
        },
        {
            name = "hyprlang",
            pattern = "hypr/.+%.conf$",
        },
        {
            name = "rasi",
            pattern = "%.rasi$",
        },
        {
            name = "dts",
            pattern = "%.overlay$"
        }
    },
}

---@param match string
local function setup_filetype(match)
    local known_type = {}
    local primary, secondary = {}, {}

    local function add_type(list, filetype)
        if known_type[filetype] or filetype == "" then return end
        known_type[filetype] = true
        table.insert(list, filetype)
    end

    local cond = function(_, p)
        return match:match(p) ~= nil
    end

    -- ------------------------------------------------------------------------

    local override_type

    for _, map in user.filetype.mapping:pairs() do
        local is_match = false
        if type(map.pattern) == "string"
            and match:match(map.pattern)
        then
            is_match = true
        elseif type(map.pattern) == "table"
            and functional_util.any(map.pattern, cond)
        then
            is_match = true
        end

        if is_match and map.condition then
            is_match = map.condition(match)
        end

        if is_match then
            local name = map.name

            local target = map.secondary and secondary or primary
            add_type(target, name)

            if map.override then
                override_type = name
                break
            end
        end
    end

    if #primary + #secondary == 0 then return end

    -- ------------------------------------------------------------------------

    local typename

    if override_type then
        typename = override_type
    else
        local old_types = vim.split(vim.opt_local.filetype:get(), ".", { plain = true })
        for _, type in ipairs(old_types) do
            add_type(primary, type)
        end

        local buffer = {}
        vim.list_extend(buffer, primary)
        vim.list_extend(buffer, secondary)
        typename = table.concat(buffer, ".")
    end

    vim.opt_local.filetype = typename
end

return function()
    -- disable all auto commenting.
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup_id,
        pattern = "*",
        callback = function(args)
            vim.opt_local.formatoptions:remove { "c", "r", "o" }

            local indent_map = user.filetype.filetype_indent()
            local filetype = args.match

            local size = indent_map[filetype]
            if size then
                local bufnr = args.buf
                local bo = vim.bo[bufnr]

                bo.tabstop = size
                bo.softtabstop = size
                bo.shiftwidth = size
            end
        end,
    })

    -- filetype mapping
    vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
        group = augroup_id,
        callback = function(info)
            setup_filetype(info.match)
        end,
    })

    -- setup filetypes that don't use soft-tab
    local no_soft_tab_filetypes = user.filetype.no_soft_tab()
    if no_soft_tab_filetypes then
        vim.api.nvim_create_autocmd("FileType", {
            group = augroup_id,
            pattern = no_soft_tab_filetypes,
            callback = function() vim.opt_local.expandtab = false end
        })
    end
end
