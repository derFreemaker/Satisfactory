local Event = require("Core.Event")

---@class Core.EventPullAdapter
---@field private events Dictionary<string, Core.Event>
---@field private logger Core.Logger
---@field OnEventPull Core.Event
local EventPullAdapter = {}

---@private
---@param eventPullData any[]
function EventPullAdapter:onEventPull(eventPullData)
    ---@type string[]
    local removeEvent = {}
    for name, event in pairs(self.events) do
        if name == eventPullData[1] then
            event:Trigger(eventPullData)
        end
        if #event:Listeners() == 0 then
            table.insert(removeEvent, name)
        end
    end
    for _, name in ipairs(removeEvent) do
        self.events[name] = nil
    end
end

---@param logger Core.Logger
---@return Core.EventPullAdapter
function EventPullAdapter:Initialize(logger)
    self.events = {}
    self.logger = logger
    self.OnEventPull = Event.new()
    return self
end

---@param signalName string
---@return Core.Event
function EventPullAdapter:GetEvent(signalName)
    for name, event in pairs(self.events) do
        if name == signalName then
            return event
        end
    end
    local event = Event.new()
    self.events[signalName] = event
    return event
end

---@param signalName string
---@param listener Core.Listener
function EventPullAdapter:AddListener(signalName, listener)
    local event = self:GetEvent(signalName)
    event:AddListener(listener)
    return self
end

---@param signalName string
---@param listener Core.Listener
function EventPullAdapter:AddListenerOnce(signalName, listener)
    local event = self:GetEvent(signalName)
    event:AddListenerOnce(listener)
    return self
end

---@param timeout number | nil
function EventPullAdapter:Wait(timeout)
    local eventPullData = table.pack(event.pull(timeout))
    if #eventPullData == 0 then
        return
    end
    self.logger:LogDebug("signalName: '".. eventPullData[1] .."' was recieved")
    self.OnEventPull:Trigger(eventPullData)
    self:onEventPull(eventPullData)
end

function EventPullAdapter:Run()
    while true do
        self:Wait()
    end
end

return EventPullAdapter