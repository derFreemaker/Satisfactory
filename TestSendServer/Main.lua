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

function Main:Configure()
    require("libs.EventPullAdapter"):Initialize(self._logger)

    local netClient = require("libs.NetworkClient.NetworkClient").new(self._logger)
    if netClient == nil then
        self._logger:LogError("netClient was nil")
        return
    end
    self.ApiClient = require("libs.Api.ApiClient").new(netClient, Config.IPAddress, 443, 443)
    self._logger:LogInfo("created net client")
end

function Main:Run()
    self._logger:LogInfo("sending message...")
    self.ApiClient:request("Test", { Message = "Test Message" })
    self._logger:LogInfo("sended message")
end

return Main
