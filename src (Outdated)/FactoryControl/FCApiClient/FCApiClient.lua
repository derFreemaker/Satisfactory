---@class FactoryControlRestApiClient
---@field RestApiClient RestApiClient
---@field Logger Logger
local FactoryControlRestApiClient = {}
FactoryControlRestApiClient.__index = FactoryControlRestApiClient

---@param apiClient RestApiClient
---@return FactoryControlRestApiClient
function FactoryControlRestApiClient.new(apiClient)
    return setmetatable({
        RestApiClient = apiClient,
        Logger = apiClient.Logger:create("FactoryControlRestApiClient")
    }, FactoryControlRestApiClient)
end

---@param controllerData ControllerData
---@return ControllerData | nil, boolean
function FactoryControlRestApiClient:CreateController(controllerData)
    local result = self.RestApiClient:request("CreateController", {ControllerData=controllerData})
    if not result.Body.Success then
        return nil, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

---@param controllerIPAddress string
---@return boolean, boolean
function FactoryControlRestApiClient:RemoveController(controllerIPAddress)
    local result = self.RestApiClient:request("RemoveController", {ControllerIPAddress=controllerIPAddress})
    if not result.Body.Success then
        return false, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

---@param controllerIPAddress string
---@return ControllerData[] | nil, boolean
function FactoryControlRestApiClient:GetController(controllerIPAddress)
    local result = self.RestApiClient:request("GetController", {ControllerIPAddress=controllerIPAddress})
    if not result.Body.Success then
        return nil, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

---@return ControllerData[] | nil, boolean
function FactoryControlRestApiClient:GetControllers()
    local result = self.RestApiClient:request("GetControllers")
    if not result.Body.Success then
        return nil, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

---@param category string
---@return ControllerData[] | nil, boolean
function FactoryControlRestApiClient:GetControllersFromCategory(category)
    local result = self.RestApiClient:request("GetControllersFromCategory", {Category=category})
    if not result.Body.Success then
        return nil, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

return FactoryControlRestApiClient