local PackageData = {}

-- ########## Test.SendServer ##########

PackageData.MFYoiWSx = {
    Namespace = "Test.SendServer.__main",
    Name = "__main",
    FullName = "__main.lua",
    IsRunnable = true,
    Data = function(...)
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local NetworkClient = require("Core.Net.NetworkClient")
local ApiClient = require("Core.Api.Client.ApiClient")
local ApiRequest = require("Core.Api.ApiRequest")
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
end
}

-- ########## Test.SendServer ########## --

return PackageData
