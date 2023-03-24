---@class ApiClient
---@field ServerIPAddress string
---@field ServerPort number
---@field ReturnPort number
---@field NetClient NetworkClient
---@field Logger Logger
local ApiClient = {}
ApiClient.__index = ApiClient

---@param netClient NetworkClient
---@param serverIPAddress string
---@param serverPort number
---@param returnPort number
function ApiClient.new(netClient, serverIPAddress, serverPort, returnPort)
    local instance = setmetatable({
        NetClient = netClient,
        ServerIPAddress = serverIPAddress,
        ServerPort = serverPort,
        ReturnPort = returnPort,
        Logger = netClient.Logger:create("ApiClient")
    }, ApiClient)
    return instance
end

---@param endpointName string
---@param data table | nil
function ApiClient:request(endpointName, data)
    self.NetClient:SendMessage(self.ServerIPAddress, self.ServerPort, endpointName, data, { ReturnPort = self.ReturnPort })
    local response = self.NetClient:WaitForEvent(endpointName, self.ReturnPort)
    response.Body.Success = response.Body.Success or false
    response.Body.Result = response.Body.Result or nil
    return response
end

return ApiClient