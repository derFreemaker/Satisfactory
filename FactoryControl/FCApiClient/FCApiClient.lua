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
---@return ControllerData | nil, boolean
function FactoryControlApiClient:CreateController(controllerData)
    local result = self.ApiClient:request("CreateController", {ControllerData=controllerData})
    if not result.Body.Success then
        return nil, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

---@param controllerIPAddress string
---@return boolean, boolean
function FactoryControlApiClient:RemoveController(controllerIPAddress)
    local result = self.ApiClient:request("RemoveController", {ControllerIPAddress=controllerIPAddress})
    if not result.Body.Success then
        return false, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

---@param controllerIPAddress string
---@return ControllerData[] | nil, boolean
function FactoryControlApiClient:GetController(controllerIPAddress)
    local result = self.ApiClient:request("GetController", {ControllerIPAddress=controllerIPAddress})
    if not result.Body.Success then
        return nil, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

---@return ControllerData[] | nil, boolean
function FactoryControlApiClient:GetControllers()
    local result = self.ApiClient:request("GetControllers")
    if not result.Body.Success then
        return nil, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

---@param category string
---@return ControllerData[] | nil, boolean
function FactoryControlApiClient:GetControllersFromCategory(category)
    local result = self.ApiClient:request("GetControllersFromCategory", {Category=category})
    if not result.Body.Success then
        return nil, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

return FactoryControlApiClient