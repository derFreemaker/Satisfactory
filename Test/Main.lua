---@class Test : Main
local Test = {}
Test.__index = Test

Test.SetupFilesTree = {
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

function Test:Configure()
    self.Logger:LogTrace("configure function called")
end

function Test:Run()
    ---@type Event
    local event = require("libs.Event")
    local event1 = event.new("Event1", self.Logger)
    local event2 = event.new("Event2", self.Logger)
    local event3 = event.new("Event3", self.Logger)
end

return Test
