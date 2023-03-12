local Main = {}
Main.__index = Main

Main.Logger = {}

Main.SetupFilesTree = {
    "",
    {
        "shared",
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

function Main:Configure()
    ModuleLoader.GetModule("EventPullAdapter"):Initialize(self.Logger)

    local networkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
    local netClient = ModuleLoader.GetModule("NetworkCard").new(self.Logger, networkCard)
    netClient:OpenPort(42)
    netClient:AddListener("Test", {Func = self.Test, Object = self}, self.Logger)
end

function Main:Test(data)
    self.Logger:LogInfo("Got Message")
    self.Logger:LogTableTrace(data)
end

function Main:Run()
    self.Logger:LogInfo("waiting for message")
    ModuleLoader.GetModule("EventPullAdapter"):Run()
end

return Main