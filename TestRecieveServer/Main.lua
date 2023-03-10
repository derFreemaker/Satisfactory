local Main = {}
Main.__index = Main

Main.Logger = {}

Main.SetupFilesTree = {
    "",
    IsFolder = true,
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

function Main:Configure()
    ModuleLoader.GetModule("EventPullAdapter"):Initialize(self.Logger)

    local networkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
    local netClient = ModuleLoader.GetModule("NetworkCard").new(self.Logger, networkCard)
    netClient:OpenPort(42)
    netClient:AddListener("Test", {Func = self.Test, Object = self}, true)
end

function Main:Test(signalName, signalSender, data)
    self.logger:LogInfo("Got Message")
end

function Main:Run()
    ModuleLoader.GetModule("EventPullAdapter"):Run()
end

return Main