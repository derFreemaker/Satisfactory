---@class FactoryControlServer : Main
local FactoryControlServer = {}
FactoryControlServer.__index = FactoryControlServer

FactoryControlServer.SetupFilesTree = {
    "",
    {
        "shared",
        { "Logger.lua" }
    },
    {
        "libs",
        {
            "NetworkClient",
            { "NetworkClient.lua" },
            { "NetworkPort.lua" },
            { "NetworkContext.lua" }
        },
        {
            "Api",
            { "ApiController.lua" },
            { "ApiClient.lua" },
            { "ApiEndpoint.lua" }
        },
        { "Listener.lua" },
        { "Event.lua" },
        { "EventPullAdapter.lua" },
        { "Serializer.lua" },
    },
    {
        "FactoryControl",
        {
            "Entities",
            { "Controller.lua" },
            { "ControllerData.lua" }
        },
        {
            "Server",
            {
                "Data",
                { "DatabaseAccessLayer.lua" }
            },
            {
                "Endpoints",
                { "ControllersEndpoint.lua" }
            }
        }
    }
}

function FactoryControlServer:Configure()
    self.Logger:LogInfo("starting server...")
    self.EventPullAdapter = require("libs.EventPullAdapter")

    self.Logger:LogTrace("initialize 'EventPullAdapater' and 'DatabaseAccessLayer'...")
    self.EventPullAdapter:Initialize(self.Logger)
    require("FactoryControl.Server.Data.DAL"):Initialize(self.Logger):load()
    self.Logger:LogTrace("initialized 'EventPullAdapater' and 'DatabaseAccessLayer'")

    self.Logger:LogTrace("creating net client...")
    local netClient = require("libs.NetworkClient.NetworkClient").new(self.Logger)
    if netClient == nil then
        error("netClient was nil")
    end
    self.Logger:LogTrace("creating net ports...")
    local controllerNetPort = netClient:CreateNetworkPort(443)
    self.Logger:LogDebug("created net client and net ports")

    self.Logger:LogTrace("configuring Endpoints...")
    require("Satisfactory.FactoryControl.Server.Data.Endpointss.ControllersEndpoint"):Configure(controllerNetPort, self.Logger)
    self.Logger:LogTrace("configured Endpoints")

    self.Logger:LogTrace("opening Ports...")
    controllerNetPort:OpenPort()
    self.Logger:LogTrace("opened Ports")
end

function FactoryControlServer:Run()
    self.Logger:LogInfo("started server")
    self.EventPullAdapter:Run()
end

return FactoryControlServer
