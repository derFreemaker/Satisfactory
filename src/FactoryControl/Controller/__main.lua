local NetworkClient = require("Core.Net.NetworkClient")
local FactoryControlRestApiClient = require("FactoryControl.Core.FactoryControlApiClient")

---@class FactoryControl.Controller.Main : Github_Loading.Entities.Main
---@field private apiClient FactoryControl.Core.FactoryControlRestApiClient
local Main = {}

function Main:Configure()
    local netClient = NetworkClient(self.Logger:subLogger("NetworkClient"))
    self.apiClient = FactoryControlRestApiClient(netClient)
    self.Logger:LogDebug("setup apiClient")
end

function Main:Run()
    local result = self.apiClient:CreateController()
    self.Logger:LogInfo("result: ".. tostring(result))
end

return Main
