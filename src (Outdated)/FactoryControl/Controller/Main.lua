---@class FactoryControlController : Main
local FactoryControlController = {}
FactoryControlController.__index = FactoryControlController

FactoryControlController.SetupFilesTree = {
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
            "RestApi",
            { "RestApiController.lua" },
            { "RestApiClient.lua" },
            { "RestApiEndpoint.lua" }
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
            {
                "Controller",
                { "Controller.lua" },
                { "ControllerData.lua" }
            }
        },
        {
            "FCRestApiClient",
            { "FCRestApiClient.lua" }
        }
    }
}

FactoryControlController.FactoryControlRestApiClient = {}

function FactoryControlController:Configure()
    require("libs.EventPullAdapter"):Initialize(self.Logger)
    local netClient = require("libs.NetworkClient.NetworkClient").new(self.Logger)
    if netClient == nil then
        error("netClient was nil")
    end
    local apiClient = require("libs.RestApi.RestApiClient").new(
        netClient,
        Config.ServerIPAddress,
        Config.ServerPort,
        Config.ReturnPort)
    self.FactoryControlRestApiClient = require("FactoryControl.FCRestApiClient.FCRestApiClient").new(apiClient)
end

function FactoryControlController:Run()
    self.Logger:LogInfo("adding controller...")
    local result = self.FactoryControlRestApiClient:CreateController({
        IPAddress = "TestIPAddress",
        Name = "Test",
        Category = "Test"
    })
    self.Logger:LogInfo("added controller")
    self.Logger:LogTableInfo(result)
end

return FactoryControlController
