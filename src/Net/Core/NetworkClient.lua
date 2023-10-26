local NetworkCardAdapter = require('Adapter.Computer.NetworkCard')
local JsonSerializer = require('Core.Json.JsonSerializer')
local EventPullAdapter = require('Core.Event.EventPullAdapter')
local Task = require('Core.Task')
local NetworkPort = require('Net.Core.NetworkPort')
local NetworkContext = require('Net.Core.NetworkContext')
local NetworkFuture = require("Net.Core.NetworkFuture")

local IPAddress = require("Net.Core.IPAddress")

---@alias Net.Core.Port
---|integer
---|"all"

---@class Net.Core.NetworkClient : object
---@field private _IPAddress Net.Core.IPAddress
---@field private _Ports Dictionary<Net.Core.Port, Net.Core.NetworkPort?>
---@field private _NetworkCard Adapter.Computer.NetworkCard
---@field private _Serializer Core.Json.Serializer
---@field private _Logger Core.Logger
---@overload fun(logger: Core.Logger, networkCard: Adapter.Computer.NetworkCard?, serializer: Core.Json.Serializer?) : Net.Core.NetworkClient
local NetworkClient = {}

---@private
---@param logger Core.Logger
---@param networkCard Adapter.Computer.NetworkCard?
---@param serializer Core.Json.Serializer?
function NetworkClient:__init(logger, networkCard, serializer)
	networkCard = networkCard or NetworkCardAdapter(1)

	self._Logger = logger
	self._Ports = {}
	self._NetworkCard = networkCard

	self._Serializer = serializer or JsonSerializer.Static__Serializer

	self._NetworkCard:Listen()
	EventPullAdapter:AddListener('NetworkMessage', Task(self.networkMessageRecieved, self))
end

---@return Net.Core.IPAddress
function NetworkClient:GetIPAddress()
	if self._IPAddress then
		return self._IPAddress
	end

	self._IPAddress = IPAddress(self._NetworkCard:GetIPAddress())
	return self._IPAddress
end

---@return string nick
function NetworkClient:GetNick()
	return self._NetworkCard:GetNick()
end

---@return Core.Json.Serializer serializer
function NetworkClient:GetJsonSerializer()
	return self._Serializer
end

---@param port Net.Core.Port
---@return Net.Core.NetworkPort?
function NetworkClient:GetNetworkPort(port)
	return self._Ports[port]
end

---@param port (Net.Core.Port)?
---@return Net.Core.NetworkPort
function NetworkClient:GetOrCreateNetworkPort(port)
	port = port or 'all'

	local networkPort = self:GetNetworkPort(port)
	if networkPort then
		return networkPort
	end

	networkPort = NetworkPort(port, self._Logger:subLogger('NetworkPort[' .. port .. ']'), self)
	self._Ports[port] = networkPort
	return networkPort
end

---@param port Net.Core.Port | Net.Core.NetworkPort?
function NetworkClient:RemoveNetworkPort(port)
	if port == "all" or type(port) == "number" then
		port = self:GetNetworkPort(port)
	end
	---@cast port Net.Core.NetworkPort?

	if not port then
		return
	end

	port:ClosePort()
	self._Ports[port] = nil
end

---@private
---@param port Net.Core.Port
---@param context Net.Core.NetworkContext
function NetworkClient:executeNetworkPort(port, context)
	local netPort = self:GetNetworkPort(port)
	if not netPort then
		return
	end

	netPort:Execute(context)
	if netPort:GetEventsCount() == 0 then
		self:RemoveNetworkPort(netPort)
	end
end

---@private
---@param data any[]
function NetworkClient:networkMessageRecieved(data)
	local context = NetworkContext(data, self._Serializer)
	self._Logger:LogDebug("recieved network message with event: '" ..
		context.EventName .. "' on port: " .. context.Port)

	self:executeNetworkPort(context.Port, context)
	self:executeNetworkPort("all", context)
end

---@param onRecivedEventName (string | "all")?
---@param onRecivedPort (Net.Core.Port)?
---@param listener Core.Task
---@return Net.Core.NetworkPort
function NetworkClient:AddListener(onRecivedEventName, onRecivedPort, listener)
	onRecivedEventName = onRecivedEventName or 'all'
	onRecivedPort = onRecivedPort or 'all'

	local networkPort = self:GetOrCreateNetworkPort(onRecivedPort)
	networkPort:AddListener(onRecivedEventName, listener)
	return networkPort
end

---@param onRecivedEventName string | "all"
---@param onRecivedPort Net.Core.Port
---@param listener Core.Task
---@return Net.Core.NetworkPort
function NetworkClient:AddListenerOnce(onRecivedEventName, onRecivedPort, listener)
	onRecivedEventName = onRecivedEventName or 'all'
	onRecivedPort = onRecivedPort or 'all'

	local networkPort = self:GetOrCreateNetworkPort(onRecivedPort)
	networkPort:AddListenerOnce(onRecivedEventName, listener)
	return networkPort
end

---@async
---@param eventName string | "all"
---@param port Net.Core.Port
---@param timeoutSeconds number?
---@return Net.Core.NetworkContext?
function NetworkClient:WaitForEvent(eventName, port, timeoutSeconds)
	local result
	---@param context Net.Core.NetworkContext
	local function set(context)
		result = context
	end

	local netPort = self:AddListenerOnce(eventName, port, Task(set))
	netPort:OpenPort()

	self._Logger:LogDebug("waiting for event: '" .. eventName .. "' on port: " .. port)
	while result == nil do
		if not EventPullAdapter:Wait(timeoutSeconds) then
			break
		end
	end

	return result
end

---@param eventName string
---@param port Net.Core.Port
---@param timeoutSeconds number?
function NetworkClient:CreateEventFuture(eventName, port, timeoutSeconds)
	return NetworkFuture(self, eventName, port, timeoutSeconds)
end

---@param port integer
function NetworkClient:Open(port)
	self._NetworkCard:OpenPort(port)
	self._Logger:LogTrace('opened Port: ' .. port)
end

---@param port integer
function NetworkClient:Close(port)
	self._NetworkCard:ClosePort(port)
	self._Logger:LogTrace('closed Port: ' .. port)
end

function NetworkClient:CloseAll()
	self._NetworkCard:CloseAllPorts()
	self._Logger:LogTrace('closed all Ports')
end

---@param ipAddress Net.Core.IPAddress
---@param port integer
---@param eventName string
---@param body any
---@param headers Dictionary<string, any>?
function NetworkClient:Send(ipAddress, port, eventName, body, headers)
	local jsonBody = self._Serializer:Serialize(body)
	local jsonHeader = self._Serializer:Serialize(headers)

	self._Logger:LogTrace(
		"sending to '" .. ipAddress:GetAddress()
		.. "' on port: " .. port
		.. " with event: '" .. eventName .. "'")

	self._NetworkCard:Send(ipAddress, port, eventName, jsonBody, jsonHeader)
end

---@param port integer
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkClient:BroadCast(port, eventName, body, header)
	local jsonBody = self._Serializer:Serialize(body)
	local jsonHeader = self._Serializer:Serialize(header)

	self._Logger:LogTrace("broadcast on port: " .. port .. " with event: '" .. eventName .. "'")

	self._NetworkCard:BroadCast(port, eventName, jsonBody, jsonHeader)
end

return Utils.Class.CreateClass(NetworkClient, 'Core.Net.NetworkClient')
