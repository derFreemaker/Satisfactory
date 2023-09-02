local RestApiNetworkClient = require("src.Core.RestApi.Client.RestApiNetworkClient")
local RestApiRequest = require("Core.RestApi.RestApiRequest")

---@class FactoryControl.Core.FactoryControlRestApiClient : object
---@field private restApiClient Core.RestApi.Client.RestApiClient
---@field private logger Core.Logger
---@overload fun(netClient: Core.Net.NetworkClient, logger: Core.Logger) : FactoryControl.Core.FactoryControlRestApiClient
local FactoryControlRestApiClient = {}

---@private
---@param netClient Core.Net.NetworkClient
---@param logger Core.Logger
function FactoryControlRestApiClient:FactoryControlRestApiClient(netClient, logger)
    self.restApiClient = RestApiNetworkClient(Config.ServerIPAddress, Config.ServerPort, 1111, netClient, self.logger:subLogger("RestApiClient"))
end

---@private
---@param method Core.RestApi.RestApiMethod
---@param endpoint string
---@param headers Dictionary<string, any>?
---@param body any
---@return Core.RestApi.RestApiResponse response
function FactoryControlRestApiClient:request(method, endpoint, headers, body)
    return self.restApiClient:request(RestApiRequest(method, endpoint, headers, body))
end

---@return boolean
function FactoryControlRestApiClient:CreateController()
    local response = self:request("CREATE", "Controller")
    return response.Body
end

return Utils.Class.CreateClass(FactoryControlRestApiClient, "FactoryControlRestApiClient")