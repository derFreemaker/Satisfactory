local PackageData = {}

-- ########## Test.RecieveServer ##########

PackageData.MFYoiWSx = {
    Namespace = "Test.RecieveServer.__main",
    Name = "__main",
    FullName = "__main.lua",
    IsRunnable = true,
    Data = [[
local Task = require("Core.Task")
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local NetworkClient = require("Core.Net.NetworkClient")
local RestApiController = require("Core.RestApi.Server.RestApiController")
local RestApiResponseTemplates = require("Core.RestApi.Server.RestApiResponseTemplates")
local Main = {}
function Main:Test(request)
    self.Logger:LogInfo("got to endpoint")
    return RestApiResponseTemplates.Ok(true)
end
function Main:Configure()
    self.eventPullAdapter = EventPullAdapter:Initialize(self.Logger:subLogger("EventPullAdapter"))
    local netClient = NetworkClient(self.Logger:subLogger("NetworkClient"))
    local netPort = netClient:CreateNetworkPort(80)
    netPort:OpenPort()
    self.apiController = RestApiController(netPort, self.Logger:subLogger("RestApiController"))
    self.apiController:AddEndpoint("GET", "Test", Task(self.Test, self))
    self.Logger:LogDebug("setup RestApiController")
end
function Main:Run()
    self.eventPullAdapter:Run()
end
return Main
]]
}

-- ########## Test.RecieveServer ########## --

return PackageData
