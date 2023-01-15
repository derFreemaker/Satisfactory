local Event = require "libs.Events.event"

local clock = os.clock
local function sleep(n)  -- seconds
    local t0 = clock()
    while clock() - t0 <= n do
    end
end

local function testfunction(funcNumber)
    print(funcNumber)
end

local function test()
    local event = Event.new()

    event:on(testfunction)
    sleep(3)

    return event
end

local event = test()
event:trigger(10)