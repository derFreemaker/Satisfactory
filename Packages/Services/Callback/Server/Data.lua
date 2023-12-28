local Data={
["Services.Callback.Server.CallbackService"] = [[
local Usage = require("Core.Usage.init")

local NetworkClient = require("Net.Core.NetworkClient")
local NetworkFuture = require("Net.Core.NetworkFuture")

local CallbackInfo = require("Services.Callback.Core.Entities.CallbackInfo")

---@class Services.Callback.Server.CallbackService : object
---@field private m_networkClient Net.Core.NetworkClient
---@field private m_logger Core.Logger
---@overload fun(logger: Core.Logger, networkClient: Net.Core.NetworkClient) : Services.Callback.Server.CallbackService
local CallbackService = {}

---@private
---@param logger Core.Logger
---@param networkClient Net.Core.NetworkClient?
function CallbackService:__init(logger, networkClient)
    self.m_logger = logger
    self.m_networkClient = networkClient or NetworkClient(logger:subLogger("NetworkClient"))
end

---@param id Core.UUID
---@param callbackMethod string
---@param callbackServiceName string
---@param ipAddress Net.Core.IPAddress
---@param args any[]
function CallbackService:Send(id, callbackMethod, callbackServiceName, ipAddress, args)
    local callbackInfo = CallbackInfo(id, callbackMethod, callbackServiceName, "Send")

    self.m_networkClient:Send(
        ipAddress,
        Usage.Ports.CallbackService,
        Usage.Events.CallbackService,
        { callbackInfo, args }
    )
end

---@param id Core.UUID
---@param callbackMethod string
---@param callbackServiceName string
---@param ipAddress Net.Core.IPAddress
---@param args any[]
---@return any[] results
function CallbackService:Invoke(id, callbackMethod, callbackServiceName, ipAddress, args)
    local callbackInfo = CallbackInfo(id, callbackMethod, callbackServiceName, "Invoke")

    local networkFuture = NetworkFuture(
        self.m_networkClient,
        Usage.Events.CallbackService_Response,
        Usage.Ports.CallbackService_Response,
        10
    )

    self.m_networkClient:Send(
        ipAddress,
        Usage.Ports.CallbackService,
        Usage.Events.CallbackService,
        { callbackInfo, args }
    )

    local context = networkFuture:Wait()
    if not context then
        error("got no callback response")
        return {}
    end

    return context.Body
end

return Utils.Class.Create(CallbackService, "Services.Callback.Server.CallbackService")

]],
}

return Data
