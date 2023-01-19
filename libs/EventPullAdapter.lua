local Event = ModuleLoader.GetModule("Event")

--[[
    If you use NetworkCard client you can not use any other event pull.
    And you can only use this to send data properly. 

    You can use the addListener method or directly under '[object].OnEventPull'. Will call like this:
    -> "func(signalName, signalSender, data)" <-
]]
local EventPullAdapter = {}
EventPullAdapter.__index = EventPullAdapter

EventPullAdapter.OnEventPull = Event.new()
EventPullAdapter.events = {}

function EventPullAdapter:AddListener(signalName, func)
    for name, event in pairs(self.events) do
        if name == signalName then
            event:addListener(func)
            return
        end
    end
    local event = Event.new()
    event:addListener(func)
    self.events[signalName] = event
end

function EventPullAdapter:Wait()
    local eventPull = {event.pull()}
    local signalName, signalSender, data = (function(signalName, signalSender, ...)
        return signalName, signalSender, {...}
    end)(table.unpack(eventPull))

    self.onEventPull:trigger(signalName, signalSender, data)
end

function EventPullAdapter:Run()
    while true do
        self:Wait()
    end
end

return EventPullAdapter