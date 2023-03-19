local Main = {}
Main.__index = Main

Main._logger = {}

Main.SetupFilesTree = {
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
            { "NetworkPort.lua" }
        },
        {
            "Api",
            { "ApiController.lua" },
            { "ApiClient.lua" }
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
            { "Controller.lua" }
        },
        {
            "Server",
            {
                "src",
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
}

function Main:Configure()
    self._logger:LogInfo("starting server...")

    self._logger:LogTrace("initialize 'DatabaseAccessLayer'...")
    require("FactoryControl.Server.src.Data.DatabaseAccessLayer"):Initialize(self._logger):load()
    self._logger:LogTrace("initialized 'EventPullAdapater' and 'DatabaseAccessLayer'")

    self._logger:LogTrace("creating net client...")
    local netClient = require("libs.NetworkClient.NetworkClient").new(self._logger)
    if netClient == nil then
        error("netClient was nil")
    end
    self._logger:LogTrace("creating net ports...")
    local controllerNetPort = netClient:CreateNetworkPort(443)
    self._logger:LogDebug("created net client and net ports")

    self._logger:LogTrace("configuring Endpoints...")
    require("ControllersEndpoint"):Configure(controllerNetPort, self._logger)
    self._logger:LogTrace("configured Endpoints")

    self._logger:LogTrace("opening Ports...")
    controllerNetPort:OpenPort()
    self._logger:LogTrace("opened Ports")
end

function Main:Run()
    self._logger:LogInfo("started server")
    require("libs.EventPullAdapter"):Run()
end

return Main
