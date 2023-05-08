---@class TestMain : Main
---@field private logger Logger
local Test = {}

---@param logger Logger
---@return string | nil
function Test:Configure(logger)
    self.logger = logger
end

return Test