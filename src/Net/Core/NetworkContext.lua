local JsonSerializer = require('Core.Json.JsonSerializer')
local IPaddress = require("Net.Core.IPAddress")

---@class Net.Core.NetworkContext.Header : table<string, any>
---@field ReturnIPAddress Net.Core.IPAddress
---@field ReturnPort integer

---@class Net.Core.NetworkContext : object
---@field SignalName string
---@field SignalSender Satisfactory.Components.Object
---@field SenderIPAddress Net.Core.IPAddress
---@field Port integer
---@field EventName string
---@field Header Net.Core.NetworkContext.Header
---@field Body any
---@overload fun(data: any[], serializer: Core.Json.Serializer?) : Net.Core.NetworkContext
local NetworkContext = {}

---@private
---@param data any[]
---@param serializer Core.Json.Serializer?
function NetworkContext:__init(data, serializer)
	if not serializer then
		serializer = JsonSerializer.Static__Serializer
	end

	self.SignalName = data[1]
	self.SignalSender = data[2]
	self.SenderIPAddress = IPaddress(data[3])
	self.Port = data[4]
	self.EventName = data[5]
	self.Body = serializer:Deserialize(data[6] or 'null')
	self.Header = serializer:Deserialize(data[7] or 'null') or {}

	if not self.Header.ReturnIPAddress then
		self.Header.ReturnIPAddress = self.SenderIPAddress
	end
end

return Utils.Class.CreateClass(NetworkContext, 'Core.Net.NetworkContext')
