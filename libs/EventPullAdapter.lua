local Event = require("Event")
local Listener = require("Listener")

local EventPullAdapter = {}
EventPullAdapter.__index = EventPullAdapter

EventPullAdapter.OnEventPull = {}
EventPullAdapter.events = {}
EventPullAdapter._logger = {}

function EventPullAdapter:onEventPull(signalName, signalSender, data)
    for eventName, event in pairs(self.events) do
        if eventName == signalName then
            event:Trigger(signalName, signalSender, data)
        end
    end
end

function EventPullAdapter:Initialize(logger)
    self._logger = logger:create("EventPullAdapter")
    self.OnEventPull = Event.new("EventPull", logger)
    self.OnEventPull:AddListener(Listener.new(self.onEventPull, self))
    return self
end

function EventPullAdapter:AddListener(signalName, listener)
    for name, event in pairs(self.events) do
        if name == signalName then
            event:AddListener(listener)
            return
        end
    end
    local event = Event.new(signalName, self._logger)
    event:AddListener(listener)
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