local Event = ModuleLoader.PreLoadModule("Event")

--[[
    If you use NetworkCard client you can not use any other event pull.
    And you can only use this to send data properly. 

    You can use the addListener method or directly under '[object].OnEventPull'. Will call like this:
    -> "func(signalName, signalSender, data)" <-
]]
local EventPullAdapter = {}
EventPullAdapter.__index = EventPullAdapter

EventPullAdapter.OnEventPull = {}
EventPullAdapter.events = {}

function EventPullAdapter:Initialize(logger)
    self.OnEventPull = Event.new("OnEventPull", logger:create("OnEventPull"))
    return self
end

function EventPullAdapter:AddListener(signalName, listener, logger)
    for name, event in pairs(self.events) do
        if name == signalName then
            event:AddListener(listener.Func, listener.Object)
            return
        end
    end
    local event = Event.new(signalName.."Event", logger)
    event:AddListener(listener.Func, listener.Object)
    self.events[signalName] = event
end

function EventPullAdapter:Wait()
    local eventPull = {event.pull()}
    local signalName, signalSender, data = (function(signalName, signalSender, ...)
        return signalName, signalSender, {...}
    end)(table.unpack(eventPull))

    self.OnEventPull:Trigger(signalName, signalSender, data)
end

function EventPullAdapter:Run()
    while true do
        self:Wait()
    end
end

return EventPullAdapter