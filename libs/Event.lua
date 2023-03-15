local Event = {}
Event.__index = Event

function Event.new(name, logger)
    if name == nil then
        name = "Event"
    else
        name = name.."Event"
    end
    local instance = {
        Funcs = {},
        OnceFuncs = {},
        _logger = logger:create(name)
    }
    instance = setmetatable(instance, Event)
    return instance
end

function Event:excuteCallback(listener, ...)
    local status, error
    local thread = coroutine.create(listener.Func)
    if listener.Object ~= nil then
        status, error = coroutine.resume(thread, listener.Object, ...)
    else
        status, error = coroutine.resume(thread, ...)
    end
    if not status then
        self._logger:LogError("trigger error: \n"..debug.traceback(thread, error) .. debug.traceback():sub(17))
    end
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
    self._logger:LogTrace("got triggered")
    for _, listener in ipairs(self.Funcs) do
        self:excuteCallback(listener, ...)
    end

    for _, listener in ipairs(self.OnceFuncs) do
        self:excuteCallback(listener, ...)
    end
    self.OnceFuncs = {}
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