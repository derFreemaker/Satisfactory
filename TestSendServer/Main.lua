local Main = {}
Main.__index = Main

Main.Logger = {}

Main.NetClient = {}

Main.SetupFilesTree = {
    "",
    {
        "shared",
        {"Logger.lua"},
        {"Utils.lua"}
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
    while true do
        self.Logger:LogInfo("sending message")
        self.NetClient:BroadCastMessage(42, "Test", {Test="Test"})
        self.Logger:LogInfo("sended message")
        Utils.Sleep(10 * 1000)
    end
end

return Main