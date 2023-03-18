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
    self._logger:LogTrace("got triggered")
    for _, listener in ipairs(self.Funcs) do
        listener:Execute(self._logger, ...)
    end

    for _, listener in ipairs(self.OnceFuncs) do
        listener:Execute(self._logger, ...)
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