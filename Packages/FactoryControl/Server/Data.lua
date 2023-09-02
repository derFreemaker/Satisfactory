local PackageData = {}

-- ########## FactoryControl.Server ##########

-- ########## FactoryControl.Server.Endpoints ##########

PackageData.llbxDAga = {
    Namespace = "FactoryControl.Server.Endpoints.ControllerEndpoints",
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

-- ########## FactoryControl.Server.Endpoints ########## --

PackageData.MBLIbtDA = {
    Namespace = "FactoryControl.Server.__main",
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
