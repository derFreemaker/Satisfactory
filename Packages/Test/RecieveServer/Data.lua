local PackageData = {}

-- ########## Test.RecieveServer ##########

PackageData.MFYoiWSx = {
    Namespace = "Test.RecieveServer.__main",
    Name = "__main",
    FullName = "__main.lua",
    IsRunnable = true,
    Data = function(...)
local Task = require("Core.Task")
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local NetworkClient = require("Core.Net.NetworkClient")
local ApiController = require("Core.Api.Server.ApiController")
local ApiResponseTemplates = require("Core.Api.Server.ApiResponseTemplates")
local Main = {}
function Main:Test(request)
    self.Logger:LogInfo("got to endpoint")
    return ApiResponseTemplates.Ok(true)
end
function Main:Configure()
    self.eventPullAdapter = EventPullAdapter:Initialize(self.Logger:subLogger("EventPullAdapter"))
    local netClient = NetworkClient(self.Logger:subLogger("NetworkClient"))
    local netPort = netClient:CreateNetworkPort(80)
    netPort:OpenPort()
    self.Logger:LogInfo("opened Port: '".. netPort.Port .."'")
    self.apiController = ApiController(netPort)
    self.apiController:AddEndpoint("Test", Task(self.Test, self))
    self.Logger:LogInfo("setup ApiController")
end
function Main:Run()
    self.eventPullAdapter:Run()
end
return Main
end
}

-- ########## Test.RecieveServer ########## --

return PackageData
