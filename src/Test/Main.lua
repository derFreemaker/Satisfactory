---@class Test.Main : Github_Loading.Entities.Main
local Test = {}

function Test:Configure()
    self.Logger:LogDebug("called configure function")
end

---@return integer
function Test:Run()
    self.Logger:LogInfo("called run function")
    return 0
end

return Test