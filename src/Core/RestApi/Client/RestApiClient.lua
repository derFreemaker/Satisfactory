local RestApiResponse = require("Core.RestApi.RestApiResponse")

---@class Core.RestApi.Client.RestApiClient : object
---@field ServerIPAddress string
---@field ServerPort integer
---@field ReturnPort integer
---@field NetClient Core.Net.NetworkClient
---@field Logger Core.Logger
---@overload fun(serverIPAddress: string, serverPort: integer, returnPort: integer, netClient: Core.Net.NetworkClient) : Core.RestApi.Client.RestApiClient
local RestApiClient = {}

---@private
---@param serverIPAddress string
---@param serverPort integer
---@param returnPort integer
---@param netClient Core.Net.NetworkClient
function RestApiClient:RestApiClient(serverIPAddress, serverPort, returnPort, netClient)
    self.ServerIPAddress = serverIPAddress
    self.ServerPort = serverPort
    self.ReturnPort = returnPort
    self.NetClient = netClient
    self.Logger = netClient.Logger:subLogger("RestApiClient")
end

---@param request Core.RestApi.RestApiRequest
---@return Core.RestApi.RestApiResponse response
function RestApiClient:request(request)
    self.NetClient:SendMessage(self.ServerIPAddress, self.ServerPort, "Rest-Request", { ReturnPort = self.ReturnPort }, request:ExtractData())
    local context = self.NetClient:WaitForEvent("Rest-Response", self.ReturnPort)
    local response = RestApiResponse.Static__CreateFromNetworkContext(context)
    return response
end

return Utils.Class.CreateClass(RestApiClient, "RestApiClient")