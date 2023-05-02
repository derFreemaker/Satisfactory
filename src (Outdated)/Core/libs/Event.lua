---@class Event
---@field private funcs Listener[]
---@field private onceFuncs Listener[]
---@field Name string
---@field Logger Logger
local Event = {}
Event.__index = Event

---@param name string
---@param logger Logger
---@return Event
function Event.new(name, logger)
    if name == nil then
        name = "Event"
    else
        name = name.."Event"
    end
    local instance = {
        funcs = {},
        onceFuncs = {},
        Logger = logger:create(name)
    }
    instance = setmetatable(instance, Event)
    return instance
end

---@param listener Listener
---@return Event
function Event:AddListener(listener)
    table.insert(self.funcs, listener)
    return self
end
Event.On = Event.AddListener

---@param listener Listener
---@return Event
function Event:AddListenerOnce(listener)
    table.insert(self.onceFuncs, listener)
    return self
end
Event.Once = Event.AddListenerOnce

---@param ... any
function Event:Trigger(...)
    for _, listener in ipairs(self.funcs) do
        listener:Execute(self.Logger, ...)
    end

    for _, listener in ipairs(self.onceFuncs) do
        listener:Execute(self.Logger, ...)
    end
    self.OnceFuncs = {}
end

---@return Listener[]
function Event:Listeners()
    local clone = {}

    for _, listener in ipairs(self.funcs) do
        table.insert(clone, {Mode = "Permanent", Listener = listener})
    end
    for _, listener in ipairs(self.onceFuncs) do
        table.insert(clone, {Mode = "Once", Listener = listener})
    end

    return clone
end

return Event