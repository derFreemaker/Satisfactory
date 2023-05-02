---@class TestSendServer : Main
local TestSendServer = {}
TestSendServer.__index = TestSendServer

TestSendServer.SetupFilesTree = {
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
            { "ApiClient.lua" }
        },
        { "Listener.lua" },
        { "Event.lua" },
        { "EventPullAdapter.lua" },
        { "Serializer.lua" },
    }
}

function TestSendServer:Configure()
    require("libs.EventPullAdapter"):Initialize(self.Logger)

    local netClient = require("libs.NetworkClient.NetworkClient").new(self.Logger)
    if netClient == nil then
        self.Logger:LogError("netClient was nil")
        return
    end
    self.ApiClient = require("libs.Api.ApiClient").new(netClient, Config.IPAddress, 443, 443)
    self.Logger:LogInfo("created net client")
end

function TestSendServer:Run()
    self.Logger:LogInfo("sending message...")
    local response = self.ApiClient:request("Test", { Message = "Test Message" })
    self.Logger:LogInfo("result: ".. tostring(response.Body.Result))
    self.Logger:LogInfo("sended message")
end

return TestSendServer
