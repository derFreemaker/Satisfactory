local PackageData = {}

-- ########## Server ##########

-- ########## Server.Endpoints ##########

PackageData.UgmxnoSZ = {
    Namespace = "Server.Endpoints.ControllerEndpoints",
    Name = "ControllerEndpoints",
    FullName = "ControllerEndpoints.lua",
    IsRunnable = true,
    Data = [[
local RestApiEndpointBase = require("Core.RestApi.Server.RestApiEndpointBase")
local ControllerEndpoints = {}
function ControllerEndpoints:CREATE__Controller(request)
    return self.Templates:Ok(true)
end
return Utils.Class.CreateSubClass(ControllerEndpoints, "ControllerEndpoints", RestApiEndpointBase)
]]
}

-- ########## Server.Endpoints ########## --

PackageData.vvWJKhpz = {
    Namespace = "Server.__main",
    Name = "__main",
    FullName = "__main.lua",
    IsRunnable = true,
    Data = [[
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local NetworkClient = require("Core.Net.NetworkClient")
local RestApiController = require("Core.RestApi.Server.RestApiController")
local ControllerEndpoints = require("FactoryControl.Server.Endpoints.ControllerEndpoints")
local Main = {}
function Main:Configure()
    self.eventPullAdapter = EventPullAdapter:Initialize(self.Logger:subLogger("EventPullAdapter"))
    local netClient = NetworkClient(self.Logger:subLogger("NetworkClient"))
    local netPort = netClient:CreateNetworkPort(80)
    netPort:OpenPort()
    self.apiController = RestApiController(netPort)
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

-- ########## Server ########## --

return PackageData
