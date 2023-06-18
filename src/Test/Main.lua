---@class TestMain : Main
---@field private logger Logger
local Test = {}

---@param logger Logger
function Test:Configure(logger)
    self.logger = logger
end

---@return integer
function Test:Run()
    self.logger:LogInfo("Running Main Module")
    local file1 = require("Test.File1")
    print(file1:Test())
    return 0
end

return Test