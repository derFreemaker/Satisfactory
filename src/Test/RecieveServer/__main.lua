local Task = require("Core.Task")
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local NetworkClient = require("Core.Net.NetworkClient")
local RestApiController = require("Core.RestApi.Server.RestApiController")
local RestApiResponseTemplates = require("Core.RestApi.Server.RestApiResponseTemplates")

---@class Test.RecieveServer.Main : Github_Loading.Entities.Main
---@field private eventPullAdapter Core.EventPullAdapter
---@field private apiController Core.RestApi.Server.RestApiController
local Main = {}

---@param request Core.RestApi.RestApiRequest
---@return Core.RestApi.RestApiResponse response
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
