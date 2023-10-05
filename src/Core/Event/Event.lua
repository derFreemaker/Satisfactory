---@class Core.Event : object
---@field private funcs Core.Task[]
---@field private onceFuncs Core.Task[]
---@operator len() : integer
---@overload fun() : Core.Event
local Event = {}

---@private
function Event:__init()
    self.funcs = {}
    self.onceFuncs = {}
end

---@param task Core.Task
---@return Core.Event
function Event:AddListener(task)
    table.insert(self.funcs, task)
    return self
end

Event.On = Event.AddListener

---@param task Core.Task
---@return Core.Event
function Event:AddListenerOnce(task)
    table.insert(self.onceFuncs, task)
    return self
end

Event.Once = Event.AddListenerOnce

---@param logger Core.Logger?
---@param ... any
function Event:Trigger(logger, ...)
    for _, task in ipairs(self.funcs) do
        task:Execute(...)
    end

    for _, task in ipairs(self.onceFuncs) do
        task:Execute(...)
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
    for _, task in ipairs(self.funcs) do
        table.insert(permanentTask, task)
    end

    ---@type Core.Task[]
    local onceTask = {}
    for _, task in ipairs(self.onceFuncs) do
        table.insert(onceTask, task)
    end
    return {
        Permanent = permanentTask,
        Once = onceTask
    }
end

---@return integer count
function Event:GetCount()
    return #self.funcs + #self.onceFuncs
end

---@param event Core.Event
---@return Core.Event event
function Event:CopyTo(event)
    for _, listener in ipairs(self.funcs) do
        event:AddListener(listener)
    end
    for _, listener in ipairs(self.onceFuncs) do
        event:AddListenerOnce(listener)
    end
    return event
end

return Utils.Class.CreateClass(Event, "Core.Event")
