---@class ControllerData
---@field IPAddress string
---@field Name string
---@field Category string
local ControllerData = {}
ControllerData.__index = ControllerData

---@param ipAddress string
---@param name string
---@param category string
function ControllerData.new(ipAddress, name, category)
    return setmetatable({
        IPAddress = ipAddress,
        Name = name,
        Category = category
    }, ControllerData)
end

return ControllerData