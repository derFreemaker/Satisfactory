---@class Github_Loading.shared.Event
---@field private funcs Github_Loading.shared.Listener[]
---@field private onceFuncs Github_Loading.shared.Listener[]
local Event = {}
Event.__index = Event

---@return Github_Loading.shared.Event
function Event.new()
    return setmetatable({
        funcs = {},
        onceFuncs = {}
    }, Event)
end

---@param listener Ficsit_Networks_Sim.Utils.Listener
---@return Github_Loading.shared.Event
function Event:AddListener(listener)
    table.insert(self.funcs, listener)
    return self
end
Event.On = Event.AddListener

---@param listener Ficsit_Networks_Sim.Utils.Listener
---@return Github_Loading.shared.Event
function Event:AddListenerOnce(listener)
    table.insert(self.onceFuncs, listener)
    return self
end
Event.Once = Event.AddListenerOnce

---@param ... any
function Event:Trigger(...)
    for _, listener in ipairs(self.funcs) do
        listener:Execute(...)
    end

    for _, listener in ipairs(self.onceFuncs) do
        listener:Execute(...)
    end
    self.OnceFuncs = {}
end

---@return Ficsit_Networks_Sim.Utils.Listener[]
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