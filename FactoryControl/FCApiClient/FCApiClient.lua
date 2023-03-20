local FactoryControlApiClient = {}
FactoryControlApiClient.__index = FactoryControlApiClient

function FactoryControlApiClient.new(apiClient)
    return setmetatable({
        ApiClient = apiClient,
        logger = apiClient._logger:create("FactoryControlApiClient")
    }, FactoryControlApiClient)
end

function FactoryControlApiClient:CreateController(controllerData)
    return self.ApiClient:request("CreateController", {ControllerData=controllerData})
end

function FactoryControlApiClient:RemoveController(controllerIPAddress)
    return self.ApiClient:request("RemoveController", {ControllerIPAddress=controllerIPAddress})
end

function FactoryControlApiClient:GetController(controllerIPAddress)
    return self.ApiClient:request("GetController", {ControllerIPAddress=controllerIPAddress})
end

function FactoryControlApiClient:GetControllers()
    return self.ApiClient:request("GetControllers")
end

function FactoryControlApiClient:GetControllersFromCategory(category)
    return self.ApiClient:request("GetControllersFromCategory", {Category=category})
end

return FactoryControlApiClient