local PackageData = {}

-- ########## FactoryControl.Core ##########

PackageData.rmhQUIAz = {
    Namespace = "FactoryControl.Core.FactoryControlApiClient",
    Name = "FactoryControlApiClient",
    FullName = "FactoryControlApiClient.lua",
    IsRunnable = true,
    Data = [[
local RestApiClient = require("Core.RestApi.Client.RestApiClient")
local RestApiRequest = require("Core.RestApi.RestApiRequest")
local FactoryControlRestApiClient = {}
function FactoryControlRestApiClient:FactoryControlRestApiClient(netClient)
    self.restApiClient = RestApiClient(Config.ServerIPAddress, Config.ServerPort, 1111, netClient)
end
function FactoryControlRestApiClient:request(method, endpoint, headers, body)
    return self.restApiClient:request(RestApiRequest(method, endpoint, headers, body))
end
function FactoryControlRestApiClient:CreateController()
    local response = self:request("CREATE", "Controller")
    return response.Body
end
return Utils.Class.CreateClass(FactoryControlRestApiClient, "FactoryControlRestApiClient")
]]
}

-- ########## FactoryControl.Core ########## --

return PackageData
