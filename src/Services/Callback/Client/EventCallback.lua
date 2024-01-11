local Event = require("Core.Event")

---@class Services.Callback.Client.EventCallback : Services.Callback.Client.Callback
---@field m_onCalled Core.Event
---@field private Handler unknown
---@field private SetHandler unknown
local EventCallback = {}

---@param id Core.UUID
---@param callbackMethod string
---@param super Services.Callback.Client.Callback.Constructor
function EventCallback:__init(super, id, callbackMethod)
    super(id, callbackMethod)

    self.m_onCalled = Event()
end

---@param task Core.Task
function EventCallback:AddTask(task)
    self.m_onCalled:AddTask(task)
end

---@param task Core.Task
function EventCallback:AddTaskOnce(task)
    self.m_onCalled:AddTaskOnce(task)
end

---@param logger Core.Logger
---@param args any[]
function EventCallback:Send(logger, args)
    self.m_onCalled:Trigger(logger, table.unpack(args))
end

---@param logger Core.Logger
---@param args any[]
function EventCallback:Invoke(logger, args)
    logger:LogError("cannot invoke event callback")
    return {}
end

return Utils.Class.Create(EventCallback, "Services.Callback.Client.EventCallback",
    require("Services.Callback.Client.Callback"))
