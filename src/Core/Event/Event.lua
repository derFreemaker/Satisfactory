---@class Core.Event : object
---@field private _Funcs Core.Task[]
---@field private _OnceFuncs Core.Task[]
---@operator len() : integer
---@overload fun() : Core.Event
local Event = {}

---@private
function Event:__init()
    self._Funcs = {}
    self._OnceFuncs = {}
end

---@param task Core.Task
---@return Core.Event
function Event:AddListener(task)
    table.insert(self._Funcs, task)
    return self
end

Event.On = Event.AddListener

---@param task Core.Task
---@return Core.Event
function Event:AddListenerOnce(task)
    table.insert(self._OnceFuncs, task)
    return self
end

Event.Once = Event.AddListenerOnce

---@param logger Core.Logger?
---@param ... any
function Event:Trigger(logger, ...)
    for _, task in ipairs(self._Funcs) do
        task:Execute(...)
        task:LogError(logger)
    end

    for _, task in ipairs(self._OnceFuncs) do
        task:Execute(...)
        task:LogError(logger)
    end
    self.OnceFuncs = {}
end

---@alias Core.Event.Mode
---|"Permanent"
---|"Once"

---@return Dictionary<Core.Event.Mode, Core.Task[]>
function Event:Listeners()
    ---@type Core.Task[]
    local permanentTask = {}
    for _, task in ipairs(self._Funcs) do
        table.insert(permanentTask, task)
    end

    ---@type Core.Task[]
    local onceTask = {}
    for _, task in ipairs(self._OnceFuncs) do
        table.insert(onceTask, task)
    end
    return {
        Permanent = permanentTask,
        Once = onceTask
    }
end

---@return integer count
function Event:GetCount()
    return #self._Funcs + #self._OnceFuncs
end

---@param event Core.Event
---@return Core.Event event
function Event:CopyTo(event)
    for _, listener in ipairs(self._Funcs) do
        event:AddListener(listener)
    end
    for _, listener in ipairs(self._OnceFuncs) do
        event:AddListenerOnce(listener)
    end
    return event
end

return Utils.Class.CreateClass(Event, "Core.Event")
