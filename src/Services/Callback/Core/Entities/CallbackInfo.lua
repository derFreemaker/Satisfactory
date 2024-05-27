---@alias Services.Callback.Core.Entities.CallbackInfo.ExecutionMode
---|"Send"
---|"Invoke"

---@class Services.Callback.Core.Entities.CallbackInfo : object, Core.Json.ISerializable
---@field Id Core.UUID
---@field CallbackMethod string
---@field CallbackServiceName string
---@field ExecutionMode Services.Callback.Core.Entities.CallbackInfo.ExecutionMode
---@overload fun(id: Core.UUID, callbackMethod: string, callbackServiceName: string, executionMode: Services.Callback.Core.Entities.CallbackInfo.ExecutionMode) : Services.Callback.Core.Entities.CallbackInfo
local CallbackInfo = {}

---@private
---@param id Core.UUID
---@param callbackServiceName string
---@param callbackMethod string
---@param executionMode Services.Callback.Core.Entities.CallbackInfo.ExecutionMode
function CallbackInfo:__init(id, callbackMethod, callbackServiceName, executionMode)
    self.Id = id
    self.CallbackMethod = callbackMethod
    self.CallbackServiceName = callbackServiceName
    self.ExecutionMode = executionMode
end

---@return Core.UUID id, string callbackMethod, string callbackServiceName, Services.Callback.Core.Entities.CallbackInfo.ExecutionMode executionMode
function CallbackInfo:Serialize()
    return self.Id, self.CallbackMethod, self.CallbackServiceName, self.ExecutionMode
end

return class("Services.Callback.Core.Entities.CallbackInfo", CallbackInfo,
    { Inherit = require("Core.Json.ISerializable") })
