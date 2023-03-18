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
        { "Listener.lua" },
        { "Event.lua" },
        { "EventPullAdapter.lua" },
        { "Serializer.lua" },
    }
}

function Main:Test()
    self._logger:LogInfo("got to endpoint")
end

function Main:Configure()
    local netClient = require("NetworkClient").new(self._logger)
    if netClient == nil then
        self._logger:LogError("netClient was nil")
        return
    end
    self.ApiClient = require("ApiClient").new(netClient, Config.IPAddress, 443, 443)
    self._logger:LogInfo("created net client")
end

function Main:Run()
    self._logger:LogInfo("sending message...")
    self.ApiClient:request("Test", { Message = "Test Message" })
    self._logger:LogInfo("sended message")
end

return Main
