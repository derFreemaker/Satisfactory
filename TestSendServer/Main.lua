local Main = {}
Main.__index = Main

Main.Logger = {}

Main.SetupFilesTree = {
    "",
    {
        "shared",
        IgnoreDownload = true,
        {"Logger.lua"}
    },
    {
        "libs",
        {"Event.lua"},
        {"Serializer.lua"},
        {"EventPullAdapter.lua"},
        {"NetworkCard.lua"}
    }
}

Main.NetClient = {}

function Main:Configure()
    ModuleLoader.GetModule("EventPullAdapter"):Initialize(self.Logger)
    local networkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
    self.NetClient = ModuleLoader.GetModule("NetworkCard").new(self.Logger, networkCard)
end

function Main:Run()
    self.Logger:LogInfo("sending message")
    self.NetClient:BroadCastMessage(42, "Test", {Test="Test"})
    self.Logger:LogInfo("sended message")
end

return Main