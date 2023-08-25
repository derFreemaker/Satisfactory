local Listener = require("Core.Event.Listener")
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local NetworkClient = require("Core.Net.NetworkClient")
local ApiController = require("Core.Api.Server.ApiController")
local ApiResponseTemplates = require("Core.Api.Server.ApiResponseTemplates")

---@class Test.RecieveServer.Main : Github_Loading.Entities.Main
---@field private eventPullAdapter Core.EventPullAdapter
---@field private apiController Core.Api.Server.ApiController
local Main = {}

---@param request Core.Api.ApiRequest
---@return Core.Api.ApiResponse response
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
    self.apiController:AddEndpoint("Test", Listener(self.Test, self))
    self.Logger:LogInfo("setup ApiController")
end

function Main:Run()
    self.eventPullAdapter:Run()
end

return Main
