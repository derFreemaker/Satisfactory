local Event = require("Core.Event.Event")

---@alias Core.LazyEventHandler.OnSetup fun(lazyEventHandler: Core.LazyEventHandler)
---@alias Core.LazyEventHandler.OnClose fun(lazyEventHandler: Core.LazyEventHandler)

---@class Core.LazyEventHandler : object
---@field private m_Event Core.Event
---@field private m_IsSetup boolean
---@field private m_OnSetup Core.LazyEventHandler.OnSetup?
---@field private m_OnClose Core.LazyEventHandler.OnClose?
---@overload fun(onSetup: Core.LazyEventHandler.OnSetup?, onClose: Core.LazyEventHandler.OnClose?) : Core.LazyEventHandler
local LazyEventHandler = {}

---@alias Core.LazyEventHandler.Constructor fun(onSetup: Core.LazyEventHandler.OnSetup?, onClose: Core.LazyEventHandler.OnClose?)

---@private
---@param onSetup Core.LazyEventHandler.OnSetup?
---@param onClose Core.LazyEventHandler.OnClose?
function LazyEventHandler:__init(onSetup, onClose)
    self.m_Event = Event()

    self.m_IsSetup = false
    self.m_OnSetup = onSetup
    self.m_OnClose = onClose
end

---@return integer count
function LazyEventHandler:Count()
    return self.m_Event:Count()
end

---@private
function LazyEventHandler:Check()
    local count = self.m_Event:Count()

    if count > 0 and not self.m_IsSetup and self.m_OnSetup then
        self.m_OnSetup(self)
        return
    end

    if count == 0 and self.m_IsSetup and self.m_OnClose then
        self.m_OnClose(self)
        return
    end
end

---@param task Core.Task
---@return Core.LazyEventHandler
function LazyEventHandler:AddTask(task)
    self.m_Event:AddTask(task)
    self:Check()
    return self
end

---@param task Core.Task
---@return Core.LazyEventHandler
function LazyEventHandler:AddTaskOnce(task)
    self.m_Event:AddTaskOnce(task)
    self:Check()
    return self
end

---@param func function
---@param ... any
---@return Core.LazyEventHandler
function LazyEventHandler:AddListener(func, ...)
    self.m_Event:AddListener(func, ...)
    self:Check()
    return self
end

---@param func function
---@param ... any
---@return Core.LazyEventHandler
function LazyEventHandler:AddListenerOnce(func, ...)
    self.m_Event:AddListenerOnce(func, ...)
    self:Check()
    return self
end

---@param logger Core.Logger?
---@param ... any
function LazyEventHandler:Trigger(logger, ...)
    self.m_Event:Trigger(logger, ...)
    self:Check()
end

return Utils.Class.CreateClass(LazyEventHandler, "Core.LazyEventHandler")
