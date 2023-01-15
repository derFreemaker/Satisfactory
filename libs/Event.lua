Event = {}
Event.__index = Event

Event.Funcs = {}
Event.OnceFuncs = {}

---@return table
function Event.new()
    local instance = setmetatable({}, Event)
    return instance
end

---@param listener function
---@return table
function Event:addListener(listener)
    table.insert(self.Funcs, listener)
    return self
end
Event.on = Event.addListener

---@param listener function
---@return table
function Event:addListenerOnce(listener)
    table.insert(self.OnceFuncs, listener)
    return self
end
Event.once = Event.addListenerOnce

function Event:trigger(...)
    for _, lsn in ipairs(self.Funcs) do
        local status, error = pcall(lsn, ...)
        if not (status) then print("trigger error: " .. tostring(error)) end
    end

    for _, lsn in ipairs(self.OnceFuncs) do
        local status, error = pcall(lsn, ...)
        if not (status) then print("trigger error: " .. tostring(error)) end
    end
    self.OnceFuncs = {}

    return self
end

function Event:listeners()
    local clone = {}

    for _, lsn in ipairs(self.Funcs) do
        table.insert(clone, lsn)
    end
    for _, lsn in ipairs(self.OnceFuncs) do
        table.insert(clone, lsn)
    end

    return clone
end

return Event