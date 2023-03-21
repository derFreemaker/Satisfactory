---@class FactoryControlApiClient
---@field ApiClient ApiClient
---@field Logger Logger
local FactoryControlApiClient = {}
FactoryControlApiClient.__index = FactoryControlApiClient

---@param apiClient ApiClient
---@return FactoryControlApiClient
function FactoryControlApiClient.new(apiClient)
    return setmetatable({
        ApiClient = apiClient,
        Logger = apiClient.Logger:create("FactoryControlApiClient")
    }, FactoryControlApiClient)
end

---@param controllerData ControllerData
---@return ControllerData
function FactoryControlApiClient:CreateController(controllerData)
    return self.ApiClient:request("CreateController", {ControllerData=controllerData})
end

---@param controllerIPAddress string
---@return boolean
function FactoryControlApiClient:RemoveController(controllerIPAddress)
    return self.ApiClient:request("RemoveController", {ControllerIPAddress=controllerIPAddress})
end

---@param controllerIPAddress string
---@return ControllerData[]
function FactoryControlApiClient:GetController(controllerIPAddress)
    return self.ApiClient:request("GetController", {ControllerIPAddress=controllerIPAddress})
end

---@return ControllerData[]
function FactoryControlApiClient:GetControllers()
    return self.ApiClient:request("GetControllers")
end

---@param category string
---@return ControllerData[]
function FactoryControlApiClient:GetControllersFromCategory(category)
    return self.ApiClient:request("GetControllersFromCategory", {Category=category})
end

return FactoryControlApiClient