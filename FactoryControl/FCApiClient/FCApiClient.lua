local FactoryControlApiClient = {}
FactoryControlApiClient.__index = FactoryControlApiClient

function FactoryControlApiClient.new(apiClient)
    return setmetatable({
        ApiClient = apiClient,
        logger = apiClient._logger:create("FactoryControlApiClient")
    }, FactoryControlApiClient)
end

function FactoryControlApiClient:CreateController(controllerData)
    local result = self.ApiClient:request("CreateController", {ControllerData=controllerData})
    if not result.Body.Success then
        return nil, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

function FactoryControlApiClient:RemoveController(controllerIPAddress)
    local result = self.ApiClient:request("RemoveController", {ControllerIPAddress=controllerIPAddress})
    if not result.Body.Success then
        return false, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

function FactoryControlApiClient:GetController(controllerIPAddress)
    local result = self.ApiClient:request("GetController", {ControllerIPAddress=controllerIPAddress})
    if not result.Body.Success then
        return nil, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

function FactoryControlApiClient:GetControllers()
    local result = self.ApiClient:request("GetControllers")
    if not result.Body.Success then
        return nil, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

function FactoryControlApiClient:GetControllersFromCategory(category)
    local result = self.ApiClient:request("GetControllersFromCategory", {Category=category})
    if not result.Body.Success then
        return nil, result.Body.Success
    end
    return result.Body.Result, result.Body.Success
end

return FactoryControlApiClient