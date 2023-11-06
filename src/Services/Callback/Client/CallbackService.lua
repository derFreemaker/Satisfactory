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
