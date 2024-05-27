---@class Core.Event : object
---@field private m_funcs Core.Task[]
---@field private m_onceFuncs Core.Task[]
---@overload fun() : Core.Event
local Event = {}

---@alias Core.Event.Constructor fun()

---@private
function Event:__init()
    self.m_funcs = {}
    self.m_onceFuncs = {}
end

---@return integer count
function Event:Count()
    return #self.m_funcs + #self.m_onceFuncs
end

---@param task Core.Task
---@return integer index
function Event:AddTask(task)
    table.insert(self.m_funcs, task)
    return #self.m_funcs
end

---@param task Core.Task
---@return integer index
function Event:AddTaskOnce(task)
    table.insert(self.m_onceFuncs, task)
    return #self.m_onceFuncs
end

---@param index integer
function Event:Remove(index)
    table.remove(self.m_funcs, index)
end

---@param index integer
function Event:RemoveOnce(index)
    table.remove(self.m_onceFuncs, index)
end

---@param logger Core.Logger?
---@param ... any
function Event:Trigger(logger, ...)
    for _, task in ipairs(self.m_funcs) do
        task:Execute(...)
        task:Close()
        task:LogError(logger)
    end

    for _, task in ipairs(self.m_onceFuncs) do
        task:Execute(...)
        task:Close()
        task:LogError(logger)
    end
    self.m_onceFuncs = {}
end

---@alias Core.Event.Mode
---|"Permanent"
---|"Once"

---@return table<Core.Event.Mode, Core.Task[]>
function Event:Listeners()
    ---@type Core.Task[]
    local permanentTask = {}
    for _, task in ipairs(self.m_funcs) do
        table.insert(permanentTask, task)
    end

    ---@type Core.Task[]
    local onceTask = {}
    for _, task in ipairs(self.m_onceFuncs) do
        table.insert(onceTask, task)
    end
    return {
        Permanent = permanentTask,
        Once = onceTask
    }
end

---@param event Core.Event
---@return Core.Event event
function Event:CopyTo(event)
    for _, listener in ipairs(self.m_funcs) do
        event:AddTask(listener)
    end
    for _, listener in ipairs(self.m_onceFuncs) do
        event:AddTaskOnce(listener)
    end
    return event
end

return class("Core.Event", Event)
