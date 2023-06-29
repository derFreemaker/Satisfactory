local Listener = require("Ficsit-Networks_Sim.Utils.Listener")

---@class Ficsit_Networks_Sim.Utils.Event
---@field private funcs Ficsit_Networks_Sim.Utils.Listener[]
---@field private onceFuncs Ficsit_Networks_Sim.Utils.Listener[]
---@field private logger Ficsit_Networks_Sim.Utils.Logger | nil
local Event = {}
Event.__index = Event

---@param logger Ficsit_Networks_Sim.Utils.Logger | nil
---@return Ficsit_Networks_Sim.Utils.Event
function Event.new(logger)
    local instance = {
        funcs = {},
        onceFuncs = {},
        logger = logger
    }
    instance = setmetatable(instance, Event)
    return instance
end

---@param listener Ficsit_Networks_Sim.Utils.Listener | function
---@param parent table | nil
---@return Ficsit_Networks_Sim.Utils.Event
function Event:AddListener(listener, parent)
    if type(listener) == "function" then
        ---@cast listener function
        listener = Listener.new(listener, parent)
        ---@cast listener Ficsit_Networks_Sim.Utils.Listener
    end
    table.insert(self.funcs, listener)
    return self
end
Event.On = Event.AddListener

---@param listener Ficsit_Networks_Sim.Utils.Listener | function
---@param parent table | nil
---@return Ficsit_Networks_Sim.Utils.Event
function Event:AddListenerOnce(listener, parent)
    if type(listener) == "function" then
        ---@cast listener function
        listener = Listener.new(listener, parent)
        ---@cast listener Ficsit_Networks_Sim.Utils.Listener
    end
    table.insert(self.onceFuncs, listener)
    return self
end
Event.Once = Event.AddListenerOnce

---@param ... any
function Event:Trigger(...)
    for _, listener in ipairs(self.funcs) do
        listener:Execute(self.logger, ...)
    end

    for _, listener in ipairs(self.onceFuncs) do
        listener:Execute(self.logger, ...)
    end
    self.OnceFuncs = {}
end

---@param onListeners Array<Ficsit_Networks_Sim.Utils.Listener>
---@param onceListeners Array<Ficsit_Networks_Sim.Utils.Listener>
function Event:AddListners(onListeners, onceListeners)
    for _, listener in ipairs(onListeners) do
        self:AddListener(listener)
    end
    for _, listener in ipairs(onceListeners) do
        self:AddListenerOnce(listener)
    end
end

---@param event Ficsit_Networks_Sim.Utils.Event
function Event:TransferListeners(event)
    for _, listener in ipairs(event.funcs) do
        self:AddListener(listener)
    end
    for _, listener in ipairs(event.onceFuncs) do
        self:AddListenerOnce(listener)
    end
end

---@return Array<Ficsit_Networks_Sim.Utils.Listener>
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