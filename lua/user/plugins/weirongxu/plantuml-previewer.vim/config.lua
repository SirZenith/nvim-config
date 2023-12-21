local user = require "user"
local fs = require "user.utils.fs"

user.option.g = {
    ["plantuml_previewer#plantuml_jar_path"] = fs.path_join(user.env.APP_PATH(), "plantuml.jar")
}
