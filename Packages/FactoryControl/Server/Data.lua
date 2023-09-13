local PackageData = {}

-- ########## FactoryControl.Server ##########

-- ########## FactoryControl.Server.Endpoints ##########

PackageData.oVIzFPpX = {
    Namespace = "FactoryControl.Server.Endpoints.ControllerEndpoints",
    Name = "ControllerEndpoints",
    FullName = "ControllerEndpoints.lua",
    IsRunnable = true,
    Data = [[
local RestApiEndpointBase = require("Net.Rest.RestApii.Server.RestApiEndpointBase")

---@class FactoryControl.Server.Endpoints.ControllerEndpoints : Core.RestApi.Server.RestApiEndpointBase
local ControllerEndpoints = {}

---@param request Core.RestApi.RestApiRequest
---@return Core.RestApi.RestApiResponse response
function ControllerEndpoints:CREATE__Controller(request)
    return self.Templates:Ok(true)
end

return Utils.Class.CreateClass(ControllerEndpoints, "ControllerEndpoints", RestApiEndpointBase)
]]
}

-- ########## FactoryControl.Server.Endpoints ########## --

PackageData.PksKdJNx = {
    Namespace = "FactoryControl.Server.__main",
    Name = "__main",
    FullName = "__main.lua",
    IsRunnable = true,
    Data = [[
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local NetworkClient = require("Net.Core.NetworkClient")
local RestApiController = require("Net.Rest.RestApii.Server.RestApiController")
local ControllerEndpoints = require("FactoryControl.Server.Endpoints.ControllerEndpoints")

---@class FactoryControl.Server.Main : Github_Loading.Entities.Main
---@field private eventPullAdapter Core.EventPullAdapter
---@field private apiController Core.RestApi.Server.RestApiController
local Main = {}

function Main:Configure()
    self.eventPullAdapter = EventPullAdapter:Initialize(self.Logger:subLogger("EventPullAdapter"))

    local netClient = NetworkClient(self.Logger:subLogger("NetworkClient"))
    local netPort = netClient:CreateNetworkPort(80)
    netPort:OpenPort()
    self.apiController = RestApiController(netPort, self.Logger:subLogger("RestApiController"))
    self.apiController:AddRestApiEndpointBase(ControllerEndpoints())
    self.Logger:LogDebug("setup endpoints")
end

function Main:Run()
    self.Logger:LogInfo("started server")
    self.eventPullAdapter:Run()
end

return Main
]]
}

-- ########## FactoryControl.Server ########## --

return PackageData
