local Data={
["Services.Callback.Client.__events"] = [==========[
require("Services.Callback.Core.Entities.CallbackInfo")

]==========],
["Services.Callback.Client.Callback"] = [==========[
---@class Services.Callback.Client.Callback : object
---@field protected Id Core.UUID
---@field protected CallbackMethod string
---@field protected Handler Core.Task?
---@overload fun(id: Core.UUID, callbackMethod: string, handler: Core.Task?) : Services.Callback.Client.Callback
local Callback = {}

---@alias Services.Callback.Client.Callback.Constructor fun(id: Core.UUID, callbackMethod: string, handler: Core.Task?) : Services.Callback.Client.Callback

---@private
---@param id Core.UUID
---@param callbackMethod string
---@param handler Core.Task?
function Callback:__init(id, callbackMethod, handler)
    self.Id = id
    self.CallbackMethod = callbackMethod
    self.Handler = handler
end

---@return Core.UUID
function Callback:GetId()
    return self.Id
end

---@return string
function Callback:GetCallbackMethod()
    return self.CallbackMethod
end

---@param task Core.Task
function Callback:SetHandler(task)
    self.Handler = task
end

---@param id Core.UUID
---@param callbackMethod string
---@return boolean
function Callback:Check(id, callbackMethod)
    if not self.Id:Equals(id) then
        return false
    end

    if self.CallbackMethod ~= callbackMethod then
        return false
    end

    return true
end

---@param logger Core.Logger
---@param args any[]
function Callback:Send(logger, args)
    if not self.Handler then
        return
    end

    self.Handler:Execute(table.unpack(args))
    self.Handler:Close()
    self.Handler:LogError(logger)
end

---@param logger Core.Logger
---@param args any[]
---@return any[] results
function Callback:Invoke(logger, args)
    if not self.Handler then
        return {}
    end

    local results = { self.Handler:Execute(table.unpack(args)) }
    self.Handler:Close()
    self.Handler:LogError(logger, false)
    return results
end

return class("Services.Callback.Client.Callback", Callback)

]==========],
["Services.Callback.Client.CallbackService"] = [==========[
local Usage = require("Core.Usage.init")

local Task = require("Core.Common.Task")
local NetworkClient = require("Net.Core.NetworkClient")

---@class Services.Callback.Client.CallbackService : object
---@field private m_name string
---@field private m_callbacks Services.Callback.Client.Callback[]
---@field private m_networkClient Net.Core.NetworkClient
---@field private m_logger Core.Logger
---@overload fun(name: string, logger: Core.Logger, networkClient: Net.Core.NetworkClient?) : Services.Callback.Client.CallbackService
local CallbackService = {}

---@private
---@param name string
---@param logger Core.Logger
---@param networkClient Net.Core.NetworkClient?
function CallbackService:__init(name, logger, networkClient)
    self.m_name = name
    self.m_callbacks = {}
    self.m_logger = logger
    self.m_networkClient = networkClient or NetworkClient(logger:subLogger("NetworkClient"))

    self.m_networkClient:AddTask(
        Usage.Events.CallbackService,
        Usage.Ports.CallbackService,
        Task(function(...)
            self:onCallbackReceived(...)
        end)
    )
    self.m_networkClient:Open(Usage.Ports.CallbackService)
end

---@param callback Services.Callback.Client.Callback
function CallbackService:AddCallback(callback)
    if self:GetCallback(callback:GetId(), callback:GetCallbackMethod()) then
        error("callback already exists")
    end
    self.m_logger:LogDebug("added callback: " .. callback:GetId():ToString() .. " - " .. callback:GetCallbackMethod())

    table.insert(self.m_callbacks, callback)
end

---@param id Core.UUID
---@param callbackMethod string
function CallbackService:RemoveCallback(id, callbackMethod)
    for i, callback in ipairs(self.m_callbacks) do
        if callback:Check(id, callbackMethod) then
            self.m_logger:LogDebug("removed callback: " .. id:ToString() .. " - " .. callbackMethod)
            table.remove(self.m_callbacks, i)
            return
        end
    end
end

---@param id Core.UUID
---@param callbackMethod string
---@return Services.Callback.Client.Callback?
function CallbackService:GetCallback(id, callbackMethod)
    for _, callback in ipairs(self.m_callbacks) do
        if callback:Check(id, callbackMethod) then
            return callback
        end
    end

    return nil
end

---@private
---@param context Net.Core.NetworkContext
function CallbackService:onCallbackReceived(context)
    local callbackInfo, args = context:GetCallback()
    if not callbackInfo.CallbackServiceName == self.m_name then
        return
    end

    self.m_logger:LogDebug("recieved callback: " .. callbackInfo.CallbackMethod)

    local callback = self:GetCallback(callbackInfo.Id, callbackInfo.CallbackMethod)
    if not callback then
        return
    end

    local callbackLogger = self.m_logger:subLogger("Callback[" .. callbackInfo.CallbackMethod .. "]")
    if callbackInfo.ExecutionMode == "Send" then
        callback:Send(callbackLogger, args)
        return
    end

    local results = callback:Invoke(callbackLogger, args)

    self.m_networkClient:Send(
        context.Header.ReturnIPAddress,
        Usage.Ports.CallbackService_Response,
        Usage.Events.CallbackService_Response,
        results
    )
end

return class("Services.Callback.Client.CallbackService", CallbackService)

]==========],
["Services.Callback.Client.EventCallback"] = [==========[
local Event = require("Core.Event.init")

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

return class("Services.Callback.Client.EventCallback", EventCallback,
    { Inherit = require("Services.Callback.Client.Callback") })

]==========],
}

return Data
