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
            "Api",
            { "ApiController.lua" },
            { "ApiClient.lua" },
            { "ApiEndpoint.lua" }
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
            { "Controller.lua" },
            { "ControllerData.lua" }
        },
        {
            "FCApiClient",
            { "FCApiClient.lua" }
        }
    }
}

FactoryControlController.FactoryControlApiClient = {}

function FactoryControlController:Configure()
    require("libs.EventPullAdapter"):Initialize(self.Logger)
    local netClient = require("libs.NetworkClient.NetworkClient").new(self.Logger)
    if netClient == nil then
        error("netClient was nil")
    end
    local apiClient = require("libs.Api.ApiClient").new(
        netClient,
        Config.ServerIPAddress,
        Config.ServerPort,
        Config.ReturnPort)
    self.FactoryControlApiClient = require("FactoryControl.FCApiClient.FCApiClient").new(apiClient)
end

function FactoryControlController:Run()
    self.Logger:LogInfo("adding controller...")
    local result = self.FactoryControlApiClient:CreateController({
        IPAddress = "TestIPAddress",
        Name = "Test",
        Category = "Test"
    })
    self.Logger:LogInfo("added controller")
    self.Logger:LogTableInfo(result)
end

return FactoryControlController
