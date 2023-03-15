local Main = {}
Main.__index = Main

Main._logger = {}

Main.SetupFilesTree = {
    "",
    {
        "shared",
        {"Logger.lua"}
    },
    {
        "libs",
        {
            "NetworkClient",
            {"NetworkClient.lua"},
            {"NetworkPort.lua"}
        },
        {
            "Api",
            {"ApiController.lua"},
            {"ApiClient.lua"}
        },
        {"Event.lua"},
        {"EventPullAdapter.lua"},
        {"Serializer.lua"},
    },
    {
        "FactoryControl",
        {
            "Entities",
            {"Controller.lua"}
        },
        {
            "Server",
            {
                "src",
                {
                    "Data",
                    {"DatabaseAccessLayer.lua"}
                },
                {
                    "Endpoints",
                    {"ControllersEndpoint.lua"}
                }
            }
        }
    }
}

function Main:Configure()
    self.Logger:LogInfo("starting server...")

    self.Logger:LogTrace("initialize 'EventPullAdapater' and 'DatabaseAccessLayer'...")
    ModuleLoader.GetModule("EventPullAdapter"):Initialize(self.Logger)
    ModuleLoader.GetModule("DatabaseAccessLayer"):Initialize(self.Logger)
    self.Logger:LogTrace("initialized 'EventPullAdapater' and 'DatabaseAccessLayer'")

    self.Logger:LogTrace("creating net client...")
    local netClient = ModuleLoader.GetModule("NetworkClient").new(self.Logger)
    self.Logger:LogTrace("creating net ports...")
    local controllerNetPort = netClient:CreateNetworkPort(443)
    self.Logger:LogDebug("created net client and net ports")

    self.Logger:LogTrace("configuring Endpoints...")
    ModuleLoader.GetModule("ControllersEndpoint"):Configure(controllerNetPort, self.Logger)
    self.Logger:LogTrace("configured Endpoints")

    self.Logger:LogTrace("opening Ports...")
    controllerNetPort:OpenPort()
    self.Logger:LogTrace("opened Ports")
end

function Main:Run()
    self.Logger:LogInfo("started server")
    ModuleLoader.GetModule("EventPullAdapter"):Run()
end

return Main