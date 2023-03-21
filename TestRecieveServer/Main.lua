---@class TestRecieveServer : Main
local TestRecieveServer = {}
TestRecieveServer.__index = TestRecieveServer

TestRecieveServer.SetupFilesTree = {
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
            { "ApiClient.lua" },
            { "ApiController.lua" },
            { "ApiEndpoint.lua" }
        },
        { "Listener.lua" },
        { "Event.lua" },
        { "EventPullAdapter.lua" },
        { "Serializer.lua" },
    }
}

TestRecieveServer.EventPullAdapter = {}

function TestRecieveServer:Test(context)
    self.Logger:LogTableDebug(context.Body)
    self.Logger:LogInfo("got to endpoint")
    return true
end

function TestRecieveServer:Configure()
    local listener = require("libs.Listener")
    self.EventPullAdapter = require("libs.EventPullAdapter")

    self.EventPullAdapter:Initialize(self.Logger)

    local netClient = require("libs.NetworkClient.NetworkClient").new(self.Logger)
    if netClient == nil then
        self.Logger:LogError("netClient was nil")
        return
    end
    local netPort = netClient:CreateNetworkPort(443)
    if netPort == nil then
        self.Logger:LogError("netPort was nil")
        return
    end
    netPort:OpenPort()
    self.Logger:LogTrace("opened Port: '" .. netPort.Port .. "'")
    local apiController = require("libs.Api.ApiController").new(netPort)
    apiController:AddEndpoint("Test", listener.new(self.Test, self))
    self.Logger:LogTrace("created ApiController")
end

function TestRecieveServer:Run()
    self.Logger:LogInfo("waiting for message...")
    self.EventPullAdapter:Run()
end

return TestRecieveServer