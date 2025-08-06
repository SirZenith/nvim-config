local user = require "user"

user.option.g = {
    ["plantuml_previewer#plantuml_jar_path"] = vim.fs.joinpath(user.env.APP_PATH(), "plantuml.jar")
}
