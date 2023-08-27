local RestApiClient = require("Core.RestApi.Client.RestApiClient")
local RestApiRequest = require("Core.RestApi.RestApiRequest")

---@class FactoryControl.Core.FactoryControlRestApiClient : object
---@field private restApiClient Core.RestApi.Client.RestApiClient
---@overload fun(netClient: Core.Net.NetworkClient) : FactoryControl.Core.FactoryControlRestApiClient
local FactoryControlRestApiClient = {}

---@private
---@param netClient Core.Net.NetworkClient
function FactoryControlRestApiClient:FactoryControlRestApiClient(netClient)
    self.restApiClient = RestApiClient(Config.ServerIPAddress, Config.ServerPort, 1111, netClient)
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