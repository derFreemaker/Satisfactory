local NetworkCardAdapter = require('Adapter.Computer.NetworkCard')
local JsonSerializer = require('Core.Json.JsonSerializer')
local EventPullAdapter = require('Core.Event.EventPullAdapter')
local Task = require('Core.Task')
local NetworkPort = require('Net.Core.NetworkPort')
local NetworkContext = require('Net.Core.NetworkContext')

local IPAddress = require("Net.Core.IPAddress")

---@class Net.Core.NetworkClient : object
---@field private _IPAddress Net.Core.IPAddress
---@field private _Ports Dictionary<integer | "all", Net.Core.NetworkPort?>
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

---@param port integer | "all"
---@return Net.Core.NetworkPort?
function NetworkClient:GetNetworkPort(port)
	return self._Ports[port]
end

---@param port (integer | "all")?
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

---@param port integer | "all" | Net.Core.NetworkPort?
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
---@param data any[]
function NetworkClient:networkMessageRecieved(data)
	local context = NetworkContext(data, self._Serializer)
	self._Logger:LogDebug("recieved network message with event: '" ..
		context.EventName .. "' on port: " .. context.Port)

	local port = self:GetNetworkPort(context.Port)
	if port then
		port:Execute(context)
		if port:GetEventsCount() == 0 then
			self:RemoveNetworkPort(port)
		end
	end

	local allPort = self:GetNetworkPort("all")
	if allPort then
		allPort:Execute(context)
		if allPort:GetEventsCount() == 0 then
			self:RemoveNetworkPort(allPort)
		end
	end
end

---@param onRecivedEventName (string | "all")?
---@param onRecivedPort (integer | "all")?
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
---@param onRecivedPort integer | "all"
---@param listener Core.Task
---@return Net.Core.NetworkPort
function NetworkClient:AddListenerOnce(onRecivedEventName, onRecivedPort, listener)
	onRecivedEventName = onRecivedEventName or 'all'
	onRecivedPort = onRecivedPort or 'all'

	local networkPort = self:GetOrCreateNetworkPort(onRecivedPort)
	networkPort:AddListenerOnce(onRecivedEventName, listener)
	return networkPort
end

---@param eventName string | "all"
---@param port integer | "all"
---@param timeoutSeconds number?
---@return Net.Core.NetworkContext?
function NetworkClient:WaitForEvent(eventName, port, timeoutSeconds)
	self._Logger:LogDebug("waiting for event: '" .. eventName .. "' on port: " .. port)
	local result
	---@param context Net.Core.NetworkContext
	local function set(context)
		result = context
	end
	self:AddListenerOnce(eventName, port, Task(set)):OpenPort()

	while result == nil do
		if not EventPullAdapter:Wait(timeoutSeconds) then
			break
		end
	end
	return result
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
---@param header Dictionary<string, any>?
function NetworkClient:Send(ipAddress, port, eventName, body, header)
	local jsonBody = self._Serializer:Serialize(body)
	local jsonHeader = self._Serializer:Serialize(header)

	self._NetworkCard:Send(ipAddress, port, eventName, jsonBody, jsonHeader)
end

---@param port integer
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkClient:BroadCast(port, eventName, body, header)
	local jsonBody = self._Serializer:Serialize(body)
	local jsonHeader = self._Serializer:Serialize(header)

	self._NetworkCard:BroadCast(port, eventName, jsonBody, jsonHeader)
end

return Utils.Class.CreateClass(NetworkClient, 'Core.Net.NetworkClient')
