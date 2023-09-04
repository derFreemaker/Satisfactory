local ControllerData = require("FactoryControl.Entities.Controller.ControllerData")

---@class Controller
---@field private FactoryControlRestApiClient FactoryControlRestApiClient
---@field IPAddress string
---@field Name string
---@field Category string
local Controller = {}
Controller.__index = Controller

---@param ipAddress string
---@param name string
---@param category string
---@param factoryControlRestApiClient FactoryControlRestApiClient
---@return Controller
function Controller.new(ipAddress, name, category, factoryControlRestApiClient)
    return setmetatable({
        IPAddress = ipAddress,
        Name = name,
        Category = category,
        FactoryControlRestApiClient = factoryControlRestApiClient
    }, Controller)
end

---@param extractedData ControllerData
---@param factoryControlRestApiClient FactoryControlRestApiClient
---@return Controller
function Controller.newWithControllerData(extractedData, factoryControlRestApiClient)
    local instance = setmetatable(extractedData, Controller)
    instance.FactoryControlRestApiClient = factoryControlRestApiClient
    ---@cast instance Controller
    return instance
end

---@return ControllerData
function Controller:extractData()
    return ControllerData.new(self.IPAddress, self.Name, self.Category)
end

return Controller