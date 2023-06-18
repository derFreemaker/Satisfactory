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

    return 0
end

return Test