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
        { "Listener.lua" },
        { "Event.lua" },
        { "Serializer.lua" },
    }
}

function Main:Configure()
    self._logger:LogTrace("configure function called")
end

function Main:Run()
    local event = require("Event").new("Test", self.Logger)
    local event1 = event:create("Event1")
    local event2 = event:create("Event2")
    local event3 = event:create("Event3")
end

return Main
