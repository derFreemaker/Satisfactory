local ApiHelper = require("Core.Api.ApiHelper")

---@class Core.Api.Client.ApiClient : object
---@field ServerIPAddress string
---@field ServerPort integer
---@field ReturnPort integer
---@field NetClient Core.Net.NetworkClient
---@field Logger Core.Logger
---@overload fun(serverIPAddress: string, serverPort: integer, returnPort: integer, netClient: Core.Net.NetworkClient) : Core.Api.Client.ApiClient
local ApiClient = {}

---@private
---@param serverIPAddress string
---@param serverPort integer
---@param returnPort integer
---@param netClient Core.Net.NetworkClient
function ApiClient:ApiClient(serverIPAddress, serverPort, returnPort, netClient)
    self.ServerIPAddress = serverIPAddress
    self.ServerPort = serverPort
    self.ReturnPort = returnPort
    self.NetClient = netClient
    self.Logger = netClient.Logger:subLogger("ApiClient")
end

---@param request Core.Api.ApiRequest
function ApiClient:request(request)
    self.NetClient:SendMessage(self.ServerIPAddress, self.ServerPort, "Rest-Request", { ReturnPort = self.ReturnPort }, request:ExtractData())
    local context = self.NetClient:WaitForEvent("Rest-Response", self.ReturnPort)
    local response = ApiHelper.NetworkContextToApiResponse(context)
    return response
end

return Utils.Class.CreateClass(ApiClient, "ApiClient")