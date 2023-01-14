local user = require "user"
local fs = require "user.utils.fs"

user.g = {
    ["plantuml_previewer#plantuml_jar_path"] = fs.path_join(vim.env.APP_PATH, "plantuml.jar")
}
