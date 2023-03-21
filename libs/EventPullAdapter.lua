local Event = require("libs.Event")
local Listener = require("libs.Listener")

---@class EventPullAdapter
---@field private events Event[]
---@field private logger Logger
---@field OnEventPull Event
local EventPullAdapter = {}
EventPullAdapter.__index = EventPullAdapter

---@param signalName string
---@param signalSender table
---@param data string
function EventPullAdapter:onEventPull(signalName, signalSender, data)
    ---@type number[]
    local removeEvent = {}
    for pos, event in pairs(self.events) do
        if event.Name == signalName .. "Event" then
            event:Trigger(signalName, signalSender, data)
        end
        if #event:Listeners() == 0 then
            table.insert(removeEvent, pos)
        end
    end
    for _, pos in pairs(removeEvent) do
        table.remove(self.events, pos)
    end
end

---@param logger Logger
---@return EventPullAdapter
function EventPullAdapter:Initialize(logger)
    self.events = {}
    self.logger = logger:create("EventPullAdapter")
    self.OnEventPull = Event.new("EventPull", logger)
    self.OnEventPull:AddListener(Listener.new(self.onEventPull, self))
    return self
end

---@param signalName string
---@param listener Listener
---@return EventPullAdapter
function EventPullAdapter:AddListener(signalName, listener)
    for _, event in pairs(self.events) do
        if event.Name == signalName .. "Event" then
            event:AddListener(listener)
            return self
        end
    end
    local event = Event.new(signalName, self.logger)
    event:AddListener(listener)

    table.insert(self.events, event)
    return self
end

---@param signalName string
---@param listener Listener
---@return EventPullAdapter
function EventPullAdapter:AddListenerOnce(signalName, listener)
    for _, event in pairs(self.events) do
        if event.Name == signalName .. "Event" then
            event:AddListener(listener)
            return self
        end
    end
    local event = Event.new(signalName, self.logger)
    event:AddListenerOnce(listener)

    table.insert(self.events, event)
    return self
end

function EventPullAdapter:Wait()
    local eventPull = { event.pull() }
    local signalName, signalSender, data = (function(signalName, signalSender, ...)
        return signalName, signalSender, { ... }
    end)(table.unpack(eventPull))

    self.OnEventPull:Trigger(signalName, signalSender, data)
end

function EventPullAdapter:Run()
    while true do
        self:Wait()
    end
end

return EventPullAdapter
