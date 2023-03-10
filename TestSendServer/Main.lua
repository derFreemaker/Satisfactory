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

Main.NetClient = {}

function Main:Configure()
    ModuleLoader.GetModule("EventPullAdapter"):Initialize(self.Logger)
    local networkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
    self.NetClient = ModuleLoader.GetModule("NetworkCard").new(self.Logger, networkCard)
end

function Main:Run()
    self.NetClient:BroadCastMessage(42, "Test", {Test="Test"})
end

return Main