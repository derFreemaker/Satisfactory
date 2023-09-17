local Json = require("Core.Json")
local RestApiRequest = require("Net.Rest.Api.Request")
local RestApiResponse = require("Net.Rest.Api.Response")

---@class Core.Net.NetworkContext : object
---@field SignalName string
---@field SignalSender FicsIt_Networks.Components.Object
---@field SenderIPAddress string
---@field Port integer
---@field EventName string
---@field Header Dictionary<string, any>
---@field Body any
---@overload fun(data: any[]) : Core.Net.NetworkContext
local NetworkContext = {}

---@private
---@param data any[]
function NetworkContext:__init(data)
    self.SignalName = data[1]
    self.SignalSender = data[2]
    self.SenderIPAddress = data[3]
    self.Port = data[4]
    self.EventName = data[5]
    self.Header = Json.decode(data[7] or "null")
    self.Body = Json.decode(data[6] or "null")
end

---@return Net.Rest.Api.Request
function NetworkContext:ToApiRequest()
    return RestApiRequest(self.Body.Method, self.Body.Endpoint, self.Body.Body, self.Body.Headers)
end

---@return Net.Rest.Api.Response
function NetworkContext:ToApiResponse()
    return RestApiResponse(self.Body.Body, self.Body.Headers)
end

return Utils.Class.CreateClass(NetworkContext, "Core.Net.NetworkContext")
