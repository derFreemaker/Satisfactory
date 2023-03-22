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
            "FCApiClient",
            { "FCApiClient.lua" }
        }
    }
}

Main.FactoryControlApiClient = {}

function Main:Configure()
    require("libs.EventPullAdapter"):Initialize(self._logger)
    local netClient = require("libs.NetworkClient.NetworkClient").new(self._logger)
    local apiClient = require("libs.Api.ApiClient").new(
        netClient,
        Config.ServerIPAddress,
        Config.ServerPort,
        Config.ReturnPort)
    self.FactoryControlApiClient = require("FactoryControl.FCApiClient.FCApiClient").new(apiClient)
end

function Main:Run()
    self._logger:LogInfo("adding controller...")
    local result = self.FactoryControlApiClient:CreateController({
        IPAddress = "TestIPAddress",
        Name = "Test",
        Category = "Test"
    })
    self.Logger:LogInfo("added controllers")
    self.Logger:LogInfo(result.Body.Success)
    self.Logger:LogInfo(#result.Body.Result)
end

return Main
