local Logger = ModuleLoader.PreLoadModule("Logger")

local Event = {}
Event.__index = Event

Event.Funcs = {}
Event.OnceFuncs = {}
Event.logger = {}

local function excuteCallback(listener, ...)
    local status, error
    if listener.Object ~= nil then
        status, error = pcall(listener.Func, listener.Object, ...)
    else
        status, error = pcall(listener.Func, ...)
    end
    return status, error
end

function Event.new(name, logger)
    if name == nil then
        name = "Event"
    end
    local instance = setmetatable({}, Event)
    instance.logger = logger:create(name)
    return instance
end

function Event:AddListener(listener, object)
    table.insert(self.Funcs, {Func = listener, Object = object})
    return self
end
Event.On = Event.AddListener

function Event:AddListenerOnce(listener, object)
    table.insert(self.OnceFuncs, {Func = listener, Object = object})
    return self
end
Event.Once = Event.AddListenerOnce

function Event:Trigger(...)
    self.logger:LogTrace("got triggered")
    for _, listener in ipairs(self.Funcs) do
        local status, error = excuteCallback(listener, ...)
        if not (status) then self.logger:LogError("trigger error: " .. tostring(error)) end
    end

    for _, listener in ipairs(self.OnceFuncs) do
        local status, error = excuteCallback(listener, ...)
        if not (status) then self.logger:LogError("trigger error: " .. tostring(error)) end
    end
    self.OnceFuncs = {}

    return self
end

function Event:Listeners()
    local clone = {}

    for _, listener in ipairs(self.Funcs) do
        table.insert(clone, {Mode = "Permanent", Listener = listener})
    end
    for _, listener in ipairs(self.OnceFuncs) do
        table.insert(clone, {Mode = "Once", Listener = listener})
    end

    return clone
end

return Event