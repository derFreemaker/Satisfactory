local Main = {}
Main.__index = Main

Main.Logger = {}

Main.SetupFilesTree = {
    "",
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

local function Test(signalName, signalSender, data)
    print("Got Message to: "..tostring(signalSender))
end

function Main:Run()
    ModuleLoader.GetModule("EventPullAdapter"):Initialize(true)
    local netClient = ModuleLoader.GetModule("NetworkCard").new(true)
    netClient:OpenPort(42)

    local eventPullAdapter = ModuleLoader.GetModule("EventPullAdapter")
    eventPullAdapter:AddListener("NetworkMessage", Test)
    eventPullAdapter:Run()
end

return Main