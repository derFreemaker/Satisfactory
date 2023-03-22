local ApiClient = {}
ApiClient.__index = ApiClient

function ApiClient.new(netClient, serverIPAddress, serverPort, returnPort)
    local instance = setmetatable({
        NetClient = netClient,
        _logger = netClient._logger:create("ApiClient"),
        ServerIPAddress = serverIPAddress,
        ServerPort = serverPort,
        ReturnPort = returnPort
    }, ApiClient)
    return instance
end

function ApiClient:request(endpointName, data)
    self.NetClient:SendMessage(self.ServerIPAddress, self.ServerPort, endpointName, data, { ReturnPort = self.ReturnPort })
    local response = self.NetClient:WaitForEvent(endpointName, self.ReturnPort)
    response.Body.Success = response.Body.Success or false
    response.Body.Result = response.Body.Result or nil
    return response
end

return ApiClient