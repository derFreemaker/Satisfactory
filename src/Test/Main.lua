---@class TestMain : Main
local Test = {}

function Test:Configure()
    self.Logger:LogDebug("called configure function")
end

---@return integer
function Test:Run()
    self.Logger:LogInfo("Running Main Module")
    local file1 = require("Test.File1")
    print(file1:Test())
    return 0
end

return Test