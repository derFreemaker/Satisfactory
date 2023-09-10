-- local loadedFiles = {}
-- loadedFiles["/Github-Loading/Loader/Utils/File"] = { require("Github-Loading.Loader.Utils.10_File") }
-- loadedFiles["/Github-Loading/Loader/Utils/Function"] = { require("Github-Loading.Loader.Utils.10_Function") }
-- loadedFiles["/Github-Loading/Loader/Utils/Object"] = { require("Github-Loading.Loader.Utils.10_Object") }
-- loadedFiles["/Github-Loading/Loader/Utils/String"] = { require("Github-Loading.Loader.Utils.10_String") }
-- loadedFiles["/Github-Loading/Loader/Utils/Table"] = { require("Github-Loading.Loader.Utils.10_Table") }
-- loadedFiles["/Github-Loading/Loader/Utils/Class"] = { loadfile("Github-Loading/Loader/Utils/20_Class.lua")(loadedFiles) }
-- Utils = loadfile("Github-Loading/Loader/Utils/30_Index.lua")(loadedFiles) --[[@as Utils]]

-- local Task = require("src.Core.Task")
-- local Logger = require("src.Core.Logger")

-- local testLogger = Logger("Test", 0)
-- testLogger.OnLog:AddListener(Task(print))

-- local function testFunc()
--     error("Test")
-- end

-- local test = Task(testFunc)

-- test:Execute()

-- test:LogError(testLogger)

print("#### END ####")