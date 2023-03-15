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
        {"EventPullAdapter"},
        {"Serializer.lua"},
    },
    {
        "FactoryControl",
        {
            "Entities",
            {"Controller.lua"}
        },
        {
            "FactoryControlApiClient",
            {"FactoryControlApiClient.lua"}
        }
    }
}

Main.FactoryControlApiClient = {}

function Main:Configure()
    local netClient = ModuleLoader.GetModule("NetworkClient").new(self._logger)
    local apiClient = ModuleLoader.GetModule("ApiClient").new(netClient, Config.ServerIPAddress, Config.ServerPort, Config.ReturnPort)
    self.FactoryControlApiClient = ModuleLoader.GetModule("FactoryControlApiClient").new(apiClient)
end

function Main:Run()
    local result = self.FactoryControlApiClient:GetControllers()
    self.Logger:LogInfo(result.Body.Success)
    self.Logger:LogInfo(#result.Body.Result)
end

return Main