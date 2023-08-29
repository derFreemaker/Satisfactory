-- local Object = require("Github-Loading.Loader.10_Object")
-- local loadedFiles = {}
-- loadedFiles["/Github-Loading/Loader/Object"] = table.pack(Object)
-- Utils = loadfile("Github-Loading/Loader/20_Utils.lua")(loadedFiles) --[[@as Utils]]

local testTable = {
    test1 = "Hi 1",
    test2 = "Hi 2",
    test3 = "Hi 3",
    test4 = "Hi 4",
}

local function test(t)
    return next, t, nil
end

setmetatable(testTable, { __pairs = test })

for key, value in pairs(testTable) do
    print(key, value)
end

print("#### END ####")