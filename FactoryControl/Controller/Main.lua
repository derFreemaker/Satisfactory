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
        { "EventPullAdapter" },
        { "Serializer.lua" },
    },
    {
        "FactoryControl",
        {
            "Entities",
            { "Controller.lua" }
        },
        {
            "FactoryControlApiClient",
            { "FactoryControlApiClient.lua" }
        }
    }
}

Main.FactoryControlApiClient = {}

function Main:Configure()
    local netClient = require("libs.NetworkClient.NetworkClient").new(self._logger)
    local apiClient = require("libs.Api.ApiClient").new(
        netClient,
        Config.ServerIPAddress,
        Config.ServerPort,
        Config.ReturnPort)
    self.FactoryControlApiClient = require("FactoryControl.FactoryControlApiClient.FactoryControlApiClient").new(apiClient)
end

function Main:Run()
    self._logger:LogInfo("adding controller...")
    local result = self.FactoryControlApiClient:CreateController({
        IPAddress = "TestIPAddress",
        Name = "Test",
        Category = "Test"
    })
    self._logger:LogInfo("added controllers")
    self._logger:LogInfo(result.Body.Success)
    self._logger:LogInfo(#result.Body.Result)
end

return Main
