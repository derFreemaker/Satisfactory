local Listener = require("Listener")

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
        { "Event.lua" },
        { "EventPullAdapter.lua" },
        { "Serializer.lua" },
    }
}

function Main:Test(context)
    self._logger:LogTableDebug(context.Body)
    self._logger:LogInfo("got to endpoint")
end

function Main:Configure()
    require("EventPullAdapter"):Initialize(self._logger)

    local netClient = require("NetworkClient").new(self._logger)
    if netClient == nil then
        self._logger:LogError("netClient was nil")
        return
    end
    local netPort = netClient:CreateNetworkPort(443)
    if netPort == nil then
        self._logger:LogError("netPort was nil")
        return
    end
    local apiController = require("ApiController").new(netPort)
    apiController:AddEndpoint("Test", Listener.new(self.Test, self))
    self._logger:LogTrace("created ApiController")
end

function Main:Run()
    self._logger:LogInfo("waiting for message...")
    require("EventPullAdapter"):Run()
end

return Main
