---@class Test.Main : Github_Loading.Main
local Test = {}

function Test:Configure()
    self.Logger:LogDebug("called configure function")
end

---@return integer
function Test:Run()
    self.Logger:LogInfo("called run function")
    local test = require("Core.Test")
    print(test)
    return 0
end

return Test