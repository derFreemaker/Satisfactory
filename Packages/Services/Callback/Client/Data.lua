---@meta
local PackageData = {}

PackageData["ServicesCallbackClient__events"] = {
    Location = "Services.Callback.Client.__events",
    Namespace = "Services.Callback.Client.__events",
    IsRunnable = true,
    Data = [[
require("Services.Callback.Core.Entities.CallbackInfo")
]]
}

PackageData["ServicesCallbackClientCallback"] = {
    Location = "Services.Callback.Client.Callback",
    Namespace = "Services.Callback.Client.Callback",
    IsRunnable = true,
    Data = [[
---@class Services.Callback.Client.Callback : object
---@field private m_id Core.UUID
---@field private m_callbackMethod string
---@field private m_handler Core.Task
---@overload fun(id: Core.UUID, callbackMethod: string, handler: Core.Task) : Services.Callback.Client.Callback
local Callback = {}

---@private
---@param id Core.UUID
---@param callbackMethod string
---@param handler Core.Task
function Callback:__init(id, callbackMethod, handler)
    self.m_id = id
    self.m_callbackMethod = callbackMethod
    self.m_handler = handler
end

---@return Core.UUID
function Callback:GetId()
    return self.m_id
end

---@return string
function Callback:GetCallbackMethod()
    return self.m_callbackMethod
end

---@param id Core.UUID
---@param callbackMethod string
---@return boolean
function Callback:Check(id, callbackMethod)
    if not self.m_id:Equals(id) then
        return false
    end

    if self.m_callbackMethod ~= callbackMethod then
        return false
    end

    return true
end

---@param logger Core.Logger
---@param args any[]
---@return any[] results
function Callback:Invoke(logger, args)
    local results = { self.m_handler:Execute(table.unpack(args)) }
    self.m_handler:LogError(logger)
    return results
end

return Utils.Class.CreateClass(Callback, "Services.Callback.Client.Callback")
]]
}

PackageData["ServicesCallbackClientCallbackService"] = {
    Location = "Services.Callback.Client.CallbackService",
    Namespace = "Services.Callback.Client.CallbackService",
    IsRunnable = true,
    Data = [[
local Usage = require("Core.Usage")

local Task = require("Core.Common.Task")
local NetworkClient = require("Net.Core.NetworkClient")

---@class Services.Callback.Client.CallbackService : object
---@field private m_name string
---@field private m_callbacks Services.Callback.Client.Callback[]
---@field private m_networkClient Net.Core.NetworkClient
---@field private m_logger Core.Logger
---@overload fun(logger: Core.Logger, networkClient: Net.Core.NetworkClient?) : Services.Callback.Client.CallbackService
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

    self.m_networkClient:AddListener(
        Usage.Events.CallbackService,
        Usage.Ports.CallbackService,
        self.onCallbackRecieved, self
    )
end

---@param callback Services.Callback.Client.Callback
function CallbackService:AddCallback(callback)
    if self:GetCallback(callback:GetId(), callback:GetCallbackMethod()) then
        error("callback already exists")
    end

    table.insert(self.m_callbacks, callback)
end

---@param id Core.UUID
---@param callbackMethod string
function CallbackService:RemoveCallback(id, callbackMethod)
    for i, callback in ipairs(self.m_callbacks) do
        if callback:Check(id, callbackMethod) then
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
function CallbackService:onCallbackRecieved(context)
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
        callback:Invoke(callbackLogger, args)
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

return Utils.Class.CreateClass(CallbackService, "Services.Callback.Client.CallbackService")
]]
}

return PackageData
