-- local Object = require("Github-Loading.Loader.10_Object")
-- local loadedFiles = {}
-- loadedFiles["/Github-Loading/Loader/Object"] = table.pack(Object)
-- Utils = loadfile("Github-Loading/Loader/20_Utils.lua")(loadedFiles) --[[@as Utils]]

for key, value in pairs(table.pack(nil)) do
    print(key, value)
end

print("#### END ####")