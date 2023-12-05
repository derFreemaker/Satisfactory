local FileSystem = require("Tools.FileSystem")

local args = { ... }
if #args < 1 then
    error("not all args given")
end

local ApiDocumentations = FileSystem.Path(args[1])

-- create documentation
