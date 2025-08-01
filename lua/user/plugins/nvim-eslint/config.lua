local user = require "user"

user.plugin.nvim_eslint = {
    __newentry = true,

    -- Toggle debug mode for ESLint language server, see debugging part
    debug = false,

    -- Command to launch language server. You might hardly want to change this setting
    -- cmd = M.create_cmd(),

    -- root_dir is used by Neovim LSP client API to determine if to attach or launch new LSP
    -- The default configuration uses the git root folder as the root_dir
    -- For monorepo it can have many projects, so launching too many LSP for one workspace is not efficient
    -- You can override it with passing function(bufnr)
    -- It should receive active buffer number and return root_dir
    -- root_dir = M.resolve_git_dir(args.buf),

    -- A table used to determine what filetypes trigger the start of LSP
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "vue",
        "svelte",
        "astro"
    },

    -- The client capabilities for LSP Protocol. See Nvim LSP docs for details
    -- It uses the default Nvim LSP client capabilities. Adding the capability to dynamically change configs
    -- capabilities = M.make_client_capabilities(),

    --[[ handlers = {
        -- The handlers handles language server responses. See Nvim LSP docs for details
        -- The default handlers only has a rewrite of default "workspace/configuration" handler of Nvim LSP
        -- Basically, when you load a new buffer, ESLint LSP requests the settings with this request
        -- To make it work with monorepo, the workingDirectory setting needs to be calculated at runtime
        -- This is the main reaason for rewriting, and it also works if you have a simple structure repo
        -- You might add more custom handler with reference to LSP protocol spec and vscode-eslint code
    }, ]]

    -- The settings send to ESLint LSP. See below part for details.
    settings = {
        validate = 'on',
        -- packageManager = 'pnpm',
        useESLintClass = true,
        useFlatConfig = function(bufnr)
            return M.use_flat_config(bufnr)
        end,
        experimental = { useFlatConfig = false },
        codeAction = {
            disableRuleComment = {
                enable = true,
                location = 'separateLine',
            },
            showDocumentation = {
                enable = true,
            },
        },
        codeActionOnSave = { mode = 'all' },
        format = false,
        quiet = false,
        onIgnoredFiles = 'off',
        options = {},
        rulesCustomizations = {},
        run = 'onType',
        problems = { shortenToSingleLine = false },
        nodePath = function(bufnr)
            return M.resolve_node_path()
        end,
        workingDirectory = { mode = 'location' },
        workspaceFolder = function(bufnr)
            local git_dir = M.resolve_git_dir(bufnr)
            return {
                uri = vim.uri_from_fname(git_dir),
                name = vim.fn.fnamemodify(git_dir, ':t'),
            }
        end,
    }
}

return user.plugin.nvim_eslint:with_wrap(function(value)
    require "nvim-eslint".setup(value)
end)
