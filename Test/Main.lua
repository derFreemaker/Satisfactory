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
    }
}

function Main:Configure()
    self.Logger:LogTrace("configure function called")
end

function Main:Run()
    local event = ModuleLoader.GetModule("Event").new("Test", self.Logger)
    local event1 = event:create("Event1")
    local event2 = event:create("Event2")
    local event3 = event:create("Event3")
end

return Main