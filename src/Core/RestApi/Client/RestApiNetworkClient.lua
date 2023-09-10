local RestApiResponse = require("Core.RestApi.RestApiResponse")

---@class Core.RestApi.Client.RestApiClient : object
---@field ServerIPAddress string
---@field ServerPort integer
---@field ReturnPort integer
---@field private NetClient Core.Net.NetworkClient
---@field private logger Core.Logger
---@overload fun(serverIPAddress: string, serverPort: integer, returnPort: integer, netClient: Core.Net.NetworkClient, logger: Core.Logger) : Core.RestApi.Client.RestApiClient
local RestApiClient = {}

---@private
---@param serverIPAddress string
---@param serverPort integer
---@param returnPort integer
---@param netClient Core.Net.NetworkClient
---@param logger Core.Logger
function RestApiClient:__init(serverIPAddress, serverPort, returnPort, netClient, logger)
    self.ServerIPAddress = serverIPAddress
    self.ServerPort = serverPort
    self.ReturnPort = returnPort
    self.NetClient = netClient
    self.logger = logger
end

---@param request Core.RestApi.RestApiRequest
---@return Core.RestApi.RestApiResponse response
function RestApiClient:request(request)
    self.NetClient:SendMessage(self.ServerIPAddress, self.ServerPort, "Rest-Request", request:ExtractData(), { ReturnPort = self.ReturnPort })
    local context = self.NetClient:WaitForEvent("Rest-Response", self.ReturnPort, 5)
    if not context then
        return RestApiResponse(nil, { Code = 408 })
    end
    local response = context:ToApiResponse()
    return response
end

return Utils.Class.CreateClass(RestApiClient, "Core.RestApi.Client.RestApiNetworkClient")