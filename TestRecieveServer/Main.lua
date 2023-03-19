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
            { "ApiClient.lua" }
        },
        { "Listener.lua" },
        { "Event.lua" },
        { "EventPullAdapter.lua" },
        { "Serializer.lua" },
    }
}

Main.EventPullAdapter = {}

function Main:Test(context)
    self._logger:LogTableDebug(context.Body)
    self._logger:LogInfo("got to endpoint")
end

function Main:Configure()
    local listener = require("libs.Listener")
    self.EventPullAdapter = require("libs.EventPullAdapter")

    self.EventPullAdapter:Initialize(self._logger)

    local netClient = require("libs.NetworkClient.NetworkClient").new(self._logger)
    if netClient == nil then
        self._logger:LogError("netClient was nil")
        return
    end
    local netPort = netClient:CreateNetworkPort(443)
    if netPort == nil then
        self._logger:LogError("netPort was nil")
        return
    end
    local apiController = require("libs.Api.ApiController").new(netPort)
    apiController:AddEndpoint("Test", listener.new(self.Test, self))
    self._logger:LogTrace("created ApiController")
end

function Main:Run()
    self._logger:LogInfo("waiting for message...")
    self.EventPullAdapter:Run()
end

return Main