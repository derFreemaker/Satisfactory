local RestApiResponse = require("Core.RestApi.RestApiResponse")

---@class Net.Rest.Api.Client : object
---@field ServerIPAddress string
---@field ServerPort integer
---@field ReturnPort integer
---@field private NetClient Core.Net.NetworkClient
---@field private logger Core.Logger
---@overload fun(serverIPAddress: string, serverPort: integer, returnPort: integer, netClient: Core.Net.NetworkClient, logger: Core.Logger) : Net.Rest.Api.Client
local Client = {}

---@private
---@param serverIPAddress string
---@param serverPort integer
---@param returnPort integer
---@param netClient Core.Net.NetworkClient
---@param logger Core.Logger
function Client:__init(serverIPAddress, serverPort, returnPort, netClient, logger)
    self.ServerIPAddress = serverIPAddress
    self.ServerPort = serverPort
    self.ReturnPort = returnPort
    self.NetClient = netClient
    self.logger = logger
end

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function Client:request(request)
    self.NetClient:SendMessage(self.ServerIPAddress, self.ServerPort, "Rest-Request", request:ExtractData(), { ReturnPort = self.ReturnPort })
    local context = self.NetClient:WaitForEvent("Rest-Response", self.ReturnPort, 5)
    if not context then
        return RestApiResponse(nil, { Code = 408 })
    end
    local response = context:ToApiResponse()
    return response
end

return Utils.Class.CreateClass(Client, "Net.Rest.Api.Client")
