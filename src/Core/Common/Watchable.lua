local Event = require("Core.Event")

---@alias Core.Watchable.OnSetup fun(Watchable: Core.Watchable)
---@alias Core.Watchable.OnClose fun(Watchable: Core.Watchable)

---@class Core.Watchable : object
---@field private m_Event Core.Event
---@field private m_IsSetup boolean
---@field private m_OnSetup Core.Watchable.OnSetup?
---@field private m_OnClose Core.Watchable.OnClose?
---@overload fun(onSetup: Core.Watchable.OnSetup?, onClose: Core.Watchable.OnClose?) : Core.Watchable
local Watchable = {}

---@alias Core.Watchable.Constructor fun(onSetup: Core.Watchable.OnSetup?, onClose: Core.Watchable.OnClose?)

---@private
---@param onSetup Core.Watchable.OnSetup?
---@param onClose Core.Watchable.OnClose?
function Watchable:__init(onSetup, onClose)
    self.m_Event = Event()

    self.m_IsSetup = false
    self.m_OnSetup = onSetup
    self.m_OnClose = onClose
end

---@return integer count
function Watchable:Count()
    return self.m_Event:Count()
end

---@private
---@param onlyClose boolean?
function Watchable:Check(onlyClose)
    local count = self.m_Event:Count()

    if count > 0 and not self.m_IsSetup and self.m_OnSetup and not onlyClose then
        self.m_OnSetup(self)
        self.m_IsSetup = true
        return
    end

    if count == 0 and self.m_IsSetup and self.m_OnClose then
        self.m_OnClose(self)
        self.m_IsSetup = false
        return
    end
end

---@param task Core.Task
---@return Core.Watchable
function Watchable:AddTask(task)
    self.m_Event:AddTask(task)
    self:Check()
    return self
end

---@param task Core.Task
---@return Core.Watchable
function Watchable:AddTaskOnce(task)
    self.m_Event:AddTaskOnce(task)
    self:Check()
    return self
end

---@param logger Core.Logger?
---@param ... any
function Watchable:Trigger(logger, ...)
    self.m_Event:Trigger(logger, ...)
    self:Check(true)
end

return Utils.Class.Create(Watchable, "Core.Common.Watchable")
