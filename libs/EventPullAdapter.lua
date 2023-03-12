local Event = ModuleLoader.PreLoadModule("Event")

local EventPullAdapter = {}
EventPullAdapter.__index = EventPullAdapter

EventPullAdapter.OnEventPull = {}
EventPullAdapter.events = {}
EventPullAdapter.logger = {}

function EventPullAdapter:Initialize(logger)
    self.OnEventPull = Event.new("EventPull", logger)
    self.logger = logger:create("EventPullAdapter")
    return self
end

function EventPullAdapter:AddListener(signalName, listener, logger)
    for name, event in pairs(self.events) do
        if name == signalName then
            event:AddListener(listener.Func, listener.Object)
            return
        end
    end
    local event = Event.new(signalName, logger)
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