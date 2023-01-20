local Logger = ModuleLoader.PreLoadModule("Logger")

local Event = {}
Event.__index = Event

Event.Funcs = {}
Event.OnceFuncs = {}
Event.logger = {}

function Event.new(name, debug)
    if name == nil then
        name = "Event"
    end
    if debug == nil then
        debug = false
    end
    local instance = setmetatable({}, Event)
    instance.logger = Logger.new(name, debug)
    return instance
end

function Event:AddListener(listener)
    table.insert(self.Funcs, listener)
    return self
end
Event.On = Event.AddListener

function Event:AddListenerOnce(listener)
    table.insert(self.OnceFuncs, listener)
    return self
end
Event.Once = Event.AddListenerOnce

function Event:Trigger(...)
    self.logger:LogDebug("got triggered")
    for _, listener in ipairs(self.Funcs) do
        local status, error = pcall(listener, ...)
        if not (status) then self.logger:LogError("trigger error: " .. tostring(error)) end
    end

    for _, listener in ipairs(self.OnceFuncs) do
        local status, error = pcall(listener, ...)
        if not (status) then self.logger:LogError("trigger error: " .. tostring(error)) end
    end
    self.OnceFuncs = {}

    return self
end

function Event:Listeners()
    local clone = {}

    for _, listener in ipairs(self.Funcs) do
        table.insert(clone, listener)
    end
    for _, listener in ipairs(self.OnceFuncs) do
        table.insert(clone, listener)
    end

    return clone
end

return Event