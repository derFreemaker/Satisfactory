local Framework = require("Test.Framework.Framework")

local NetworkCard = require("Adapter.Computer.NetworkCard")

local EventPullAdapter = require("Core.Event.EventPullAdapter")

local function test()
    local networkCard = NetworkCard()
    networkCard:Listen()

    networkCard:OpenPort(1)
    networkCard:Send(networkCard:GetIPAddress(), 1, "test")

    local gotEvent = false
    EventPullAdapter:AddListener("NetworkMessage", function(data)
        log(data)
        if data[5] == "test" then
            gotEvent = true
        end
    end)

    EventPullAdapter:Wait(5)

    assert(gotEvent, "did not get networkCard message")
end
Framework:AddTest("NetworkCard", test)
