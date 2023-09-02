local PackageData = {}

-- ########## Test.SendServer ##########

PackageData.QKAARTsB = {
    Namespace = "Test.SendServer.__main",
    Name = "__main",
    FullName = "__main.lua",
    IsRunnable = true,
    Data = [[
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local NetworkClient = require("Core.Net.NetworkClient")
local RestApiNetworkClient = require("Core.RestApi.Client.RestApiNetworkClient")
local RestApiRequest = require("Core.RestApi.RestApiRequest")
local Main = {}
function Main:Configure()
    EventPullAdapter:Initialize(self.Logger:subLogger("EventPullAdapter"))
    local netClient = NetworkClient(self.Logger:subLogger("NetworkClient"))
    self.apiClient = RestApiNetworkClient(Config.ServerIPAddress, Config.ServerPort, 1111, netClient, self.Logger:subLogger("RestApiClient"))
    self.Logger:LogInfo("setup RestApiClient")
end
function Main:Run()
    self.Logger:LogInfo("sending request...")
    local response = self.apiClient:request(RestApiRequest("GET", "Test"))
    self.Logger:LogInfo("result: ".. tostring(response.Body))
end
return Main
]]
}

-- ########## Test.SendServer ########## --

return PackageData
