local EventPullAdapter = require("Core.Event.EventPullAdapter")
local NetworkClient = require("Core.Net.NetworkClient")
local ApiClient = require("Core.Api.Client.ApiClient")
local ApiRequest = require("Core.Api.ApiRequest")

---@class Test.SendServer.Main : Github_Loading.Entities.Main
---@field private apiClient Core.Api.Client.ApiClient
local Main = {}

function Main:Configure()
    EventPullAdapter:Initialize(self.Logger)

    local netClient = NetworkClient(self.Logger)
    self.apiClient = ApiClient(Config.ServerIPAddress, Config.ServerPort, 1111, netClient)
    self.Logger:LogInfo("setup ApiClient")
end

function Main:Run()
    self.Logger:LogInfo("sending request...")
    local response = self.apiClient:request(ApiRequest("Test"))
    self.Logger:LogInfo("result: ".. tostring(response.Body))
end

return Main
