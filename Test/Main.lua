local Main = {}
Main.__index = Main

Main.Logger = {}

Main.SetupFilesTree = {
    "/",
    IsFolder = true,
    {
        "shared",
        IsFolder = true,
        IgnoreDownload = true,
        {"Logger.lua"}
    },
    {
        "libs",
        IsFolder = true,
        {"Event.lua"},
        {"Serializer.lua"},
        {"EventPullAdapter.lua"},
        {"NetworkCard.lua"}
    }
}

function Main:Configure()
    self.Logger:LogInfo("called configure function")
end

function Main:Test(signalName, signalSender, data)
    self.Logger:LogInfo("Got Message to: "..tostring(signalSender))
end

function Main:Run()
    local netClient = ModuleLoader.GetModule("NetworkCard").new()
    netClient:OpenPort(42)

    local eventPullAdapter = ModuleLoader.GetModule("EventPullAdapter")
    eventPullAdapter:AddListener("NetworkMessage", self.Test)
    eventPullAdapter:Run()
end

return Main