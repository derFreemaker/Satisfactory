local Tester = require("Test.Tester"):Initialize()

local Task = require("Core.Task")
local Logger = require("Core.Logger")

local testLogger = Logger("Test", 0)
testLogger.OnLog:AddListener(Task(print))

local function testFunc()
    error("Test", 2)
end

local test = Task(testFunc)

test:Execute()

test:LogError(testLogger)

print("#### END ####")