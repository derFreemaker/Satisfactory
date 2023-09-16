local PackageData = {}

PackageData.UgmxnoSZ = {
    Location = "FactoryControl.Core.FactoryControlApiClient",
    Namespace = "FactoryControl.Core.FactoryControlApiClient",
    IsRunnable = true,
    Data = [[
local RestApiNetworkClient = require("Net.Rest.RestApii.Client.RestApiNetworkClient")
local RestApiRequest = require("Net.Rest.RestApii.RestApiRequest")

---@class FactoryControl.Core.FactoryControlRestApiClient : object
---@field private restApiClient Net.Rest.Api.Client
---@field private logger Core.Logger
---@overload fun(netClient: Core.Net.NetworkClient, logger: Core.Logger) : FactoryControl.Core.FactoryControlRestApiClient
local FactoryControlRestApiClient = {}

---@private
---@param netClient Core.Net.NetworkClient
---@param logger Core.Logger
function FactoryControlRestApiClient:__init(netClient, logger)
    self.restApiClient = RestApiNetworkClient(Config.ServerIPAddress, Config.ServerPort, 1111, netClient, self.logger:subLogger("RestApiClient"))
end

---@private
---@param method Net.Rest.Api.Method
---@param endpoint string
---@param headers Dictionary<string, any>?
---@param body any
---@return Net.Rest.Api.Response response
function FactoryControlRestApiClient:request(method, endpoint, headers, body)
    return self.restApiClient:request(RestApiRequest(method, endpoint, headers, body))
end

---@return boolean
function FactoryControlRestApiClient:CreateController()
    local response = self:request("CREATE", "Controller")
    return response.Body
end

return Utils.Class.CreateClass(FactoryControlRestApiClient, "FactoryControlRestApiClient")
]]
}

return PackageData
