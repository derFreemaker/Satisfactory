local ApiClient = {}
ApiClient.__index = ApiClient

function ApiClient.new(netClient, serverIPAddress, serverPort, returnPort)
    local instance = setmetatable({
        NetClient = netClient,
        logger = netClient.logger:create("ApiClient"),
        ServerIPAddress = serverIPAddress,
        ServerPort = serverPort,
        ReturnPort = returnPort
    }, ApiClient)
    return instance
end

function ApiClient:request(endpointName, data)
    self.NetClient:SendMessage(self.ServerIPAddress, self.ServerPort, endpointName, data, {ReturnPort = self.ReturnPort})
    return self.NetClient:WaitForEvent(endpointName, self.ReturnPort)
end

return ApiClient