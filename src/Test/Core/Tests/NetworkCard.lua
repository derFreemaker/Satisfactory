local Framework = require("Test.Framework.init")

local NetworkCard = require("Adapter.Computer.NetworkCard")

local Task = require("Core.Common.Task")
local EventPullAdapter = require("Core.Event.EventPullAdapter")

local TEST_MESSAGE = "TEST_MESSAGE"

local function test()
    local networkCard = NetworkCard()
    networkCard:Listen()

    networkCard:OpenPort(1)
    networkCard:Send(networkCard:GetIPAddress(), 1, TEST_MESSAGE)

    local gotEvent = false
    EventPullAdapter:AddTask(
        "NetworkMessage",
        Task(function(data)
            log(data)
            if data[5] == TEST_MESSAGE then
                gotEvent = true
            end
        end)
    )

    EventPullAdapter:Wait(5)

    assert(gotEvent, "did not get the right networkCard message")
end

Framework:AddTest("NetworkCard", test)
