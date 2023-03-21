local ControllerData = require("FactoryControl.Entities.Controller.ControllerData")

---@class Controller
---@field private FactoryControlApiClient FactoryControlApiClient
---@field IPAddress string
---@field Name string
---@field Category string
local Controller = {}
Controller.__index = Controller

---@param ipAddress string
---@param name string
---@param category string
---@param factoryControlApiClient FactoryControlApiClient
---@return Controller
function Controller.new(ipAddress, name, category, factoryControlApiClient)
    return setmetatable({
        IPAddress = ipAddress,
        Name = name,
        Category = category,
        FactoryControlApiClient = factoryControlApiClient
    }, Controller)
end

---@param extractedData ControllerData
---@param factoryControlApiClient FactoryControlApiClient
---@return Controller
function Controller.newWithControllerData(extractedData, factoryControlApiClient)
    local instance = setmetatable(extractedData, Controller)
    instance.FactoryControlApiClient = factoryControlApiClient
    ---@cast instance Controller
    return instance
end

---@return ControllerData
function Controller:extractData()
    return ControllerData.new(self.IPAddress, self.Name, self.Category)
end

return Controller