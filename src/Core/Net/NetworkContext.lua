local Json = require("Core.Json")

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
    self.Header = Json.decode(data[6])
    self.Body = Json.decode(data[7])
end

return Utils.Class.CreateClass(NetworkContext, "Core.Net.NetworkContext")