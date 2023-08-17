---@class Core.Event : Object
---@field private funcs Core.Listener[]
---@field private onceFuncs Core.Listener[]
---@operator len() : integer
---@overload fun() : Core.Event
local Event = {}

---@private
function Event:Event()
    self.funcs = {}
    self.onceFuncs = {}
end

---@param listener Core.Listener
---@return Core.Event
function Event:AddListener(listener)
    table.insert(self.funcs, listener)
    return self
end
Event.On = Event.AddListener

---@param listener Core.Listener
---@return Core.Event
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

---@param args table
function Event:TriggerDynamic(args)
    for _, listener in ipairs(self.funcs) do
        listener:ExecuteDynamic(args)
    end

    for _, listener in ipairs(self.onceFuncs) do
        listener:ExecuteDynamic(args)
    end
    self.OnceFuncs = {}
end

---@alias Core.Event.Mode
---|"Permanent"
---|"Once"

---@return Dictionary<Core.Event.Mode, Core.Listener[]>
function Event:Listeners()
    ---@type Core.Listener[]
    local permanentListeners = {}
    for _, listener in ipairs(self.funcs) do
        table.insert(permanentListeners, listener)
    end

    ---@type Core.Listener[]
    local onceListeners = {}
    for _, listener in ipairs(self.onceFuncs) do
        table.insert(onceListeners, listener)
    end
    return {
        Permanent = permanentListeners,
        Once = onceListeners
    }
end

---@private
---@return integer count
function Event:__len()
    return #self.funcs + #self.onceFuncs
end

return Utils.Class.CreateClass(Event, "Event")
