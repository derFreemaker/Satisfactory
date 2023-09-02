local EventPullAdapter = require("Core.Event.EventPullAdapter")
local NetworkClient = require("Core.Net.NetworkClient")
local RestApiNetworkClient = require("src.Core.RestApi.Client.RestApiNetworkClient")
local RestApiRequest = require("Core.RestApi.RestApiRequest")

---@class Test.SendServer.Main : Github_Loading.Entities.Main
---@field private apiClient Core.RestApi.Client.RestApiClient
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
