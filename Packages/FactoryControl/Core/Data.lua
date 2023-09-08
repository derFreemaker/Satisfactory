local PackageData = {}

-- ########## FactoryControl.Core ##########

PackageData.MFYoiWSx = {
    Namespace = "FactoryControl.Core.FactoryControlApiClient",
    Name = "FactoryControlApiClient",
    FullName = "FactoryControlApiClient.lua",
    IsRunnable = true,
    Data = [[
local RestApiNetworkClient = require("Core.RestApi.Client.RestApiNetworkClient")
local RestApiRequest = require("Core.RestApi.RestApiRequest")
local FactoryControlRestApiClient = {}
function FactoryControlRestApiClient:__call(netClient, logger)
    self.restApiClient = RestApiNetworkClient(Config.ServerIPAddress, Config.ServerPort, 1111, netClient, self.logger:subLogger("RestApiClient"))
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
