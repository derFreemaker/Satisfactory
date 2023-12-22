local NetworkCardAdapter = require('Adapter.Computer.NetworkCard')
local JsonSerializer = require('Core.Json.JsonSerializer')
local EventPullAdapter = require('Core.Event.EventPullAdapter')
local Task = require('Core.Common.Task')
local NetworkPort = require('Net.Core.NetworkPort')
local NetworkContext = require('Net.Core.NetworkContext')
local NetworkFuture = require("Net.Core.NetworkFuture")

local IPAddress = require("Net.Core.IPAddress")

---@alias Net.Core.Port
---|integer
---|"*"

---@alias Net.Core.EventName
---|string
---|"*"

---@class Net.Core.NetworkClient : object
---@field private m_iPAddress Net.Core.IPAddress
---@field private m_ports table<Net.Core.Port, Net.Core.NetworkPort?>
---@field private m_networkCard Adapter.Computer.NetworkCard
---@field private m_serializer Core.Json.Serializer
---@field private m_logger Core.Logger
---@field private m_onNetworkMessageReceivedTaskIndex integer
---@overload fun(logger: Core.Logger, networkCard: Adapter.Computer.NetworkCard?, serializer: Core.Json.Serializer?) : Net.Core.NetworkClient
local NetworkClient = {}

---@private
---@param logger Core.Logger
---@param networkCard Adapter.Computer.NetworkCard?
---@param serializer Core.Json.Serializer?
function NetworkClient:__init(logger, networkCard, serializer)
	networkCard = networkCard or NetworkCardAdapter(1)

	self.m_logger = logger
	self.m_ports = {}
	self.m_networkCard = networkCard

	self.m_serializer = serializer or JsonSerializer.Static__Serializer

	self.m_networkCard:Listen()
	self.m_onNetworkMessageReceivedTaskIndex = EventPullAdapter:AddTask(
		"NetworkMessage",
		Task(self.networkMessageReceived, self)
	)
end

---@private
function NetworkClient:__gc()
	self.m_ports = nil
	EventPullAdapter:Remove("NetworkMessage", self.m_onNetworkMessageReceivedTaskIndex)
end

function NetworkClient:Dispose()
	Utils.Class.Deconstruct(self)
end

---@return Net.Core.IPAddress
function NetworkClient:GetIPAddress()
	if self.m_iPAddress then
		return self.m_iPAddress
	end

	self.m_iPAddress = IPAddress(self.m_networkCard:GetIPAddress())
	return self.m_iPAddress
end

---@return string nick
function NetworkClient:GetNick()
	return self.m_networkCard:GetNick()
end

---@return Core.Json.Serializer serializer
function NetworkClient:GetJsonSerializer()
	return self.m_serializer
end

---@param port Net.Core.Port
---@return Net.Core.NetworkPort?
function NetworkClient:GetNetworkPort(port)
	return self.m_ports[port]
end

---@param port (Net.Core.Port)?
---@return Net.Core.NetworkPort
function NetworkClient:GetOrCreateNetworkPort(port)
	port = port or "*"

	local networkPort = self:GetNetworkPort(port)
	if networkPort then
		return networkPort
	end

	networkPort = NetworkPort(port, self.m_logger:subLogger('NetworkPort[' .. port .. ']'), self)
	self.m_ports[port] = networkPort
	return networkPort
end

---@param port Net.Core.Port | Net.Core.NetworkPort?
function NetworkClient:RemoveNetworkPort(port)
	if port == "*" or type(port) == "number" then
		port = self:GetNetworkPort(port)
	end
	---@cast port Net.Core.NetworkPort?

	if not port then
		return
	end

	port:ClosePort()
	self.m_ports[port.Port] = nil
	Utils.Class.Deconstruct(port)
end

---@private
---@param port Net.Core.Port
---@param context Net.Core.NetworkContext
---@return boolean foundPort
function NetworkClient:executeNetworkPort(port, context)
	local netPort = self:GetNetworkPort(port)
	if not netPort then
		return false
	end

	netPort:Execute(context)
	if netPort:GetEventsCount() == 0 then
		self:RemoveNetworkPort(netPort)
	end
	return true
end

---@private
---@param data any[]
function NetworkClient:networkMessageReceived(data)
	local context = NetworkContext(data, self.m_serializer)
	self.m_logger:LogDebug("received network message with event: '" ..
		context.EventName .. "' on port: " .. context.Port)


	local foundPort = self:executeNetworkPort(context.Port, context)
	if not foundPort then
		self:Close(context.Port)
	end

	self:executeNetworkPort("*", context)
end

---@param onReceivedEventName Net.Core.EventName?
---@param onReceivedPort Net.Core.Port?
---@param listener Core.Task
---@return Net.Core.NetworkPort, number taskIndex
function NetworkClient:AddTask(onReceivedEventName, onReceivedPort, listener)
	onReceivedEventName = onReceivedEventName or "*"
	onReceivedPort = onReceivedPort or "*"

	local networkPort = self:GetOrCreateNetworkPort(onReceivedPort)
	return networkPort, networkPort:AddTask(onReceivedEventName, listener)
end

---@param onReceivedEventName Net.Core.EventName
---@param onReceivedPort Net.Core.Port
---@param listener Core.Task
---@return Net.Core.NetworkPort, number taskIndex
function NetworkClient:AddTaskOnce(onReceivedEventName, onReceivedPort, listener)
	onReceivedEventName = onReceivedEventName or '*'
	onReceivedPort = onReceivedPort or "*"

	local networkPort = self:GetOrCreateNetworkPort(onReceivedPort)
	return networkPort, networkPort:AddTaskOnce(onReceivedEventName, listener)
end

---@param onReceivedEventName Net.Core.EventName?
---@param onReceivedPort Net.Core.Port?
---@param listener fun(context: Net.Core.NetworkClient)
---@param ... any
---@return Net.Core.NetworkPort, number taskIndex
function NetworkClient:AddListener(onReceivedEventName, onReceivedPort, listener, ...)
	return self:AddTask(onReceivedEventName, onReceivedPort, Task(listener, ...))
end

---@param onReceivedEventName Net.Core.EventName
---@param onReceivedPort Net.Core.Port
---@param listener fun(context: Net.Core.NetworkContext)
---@param ... any
---@return Net.Core.NetworkPort, number taskIndex
function NetworkClient:AddListenerOnce(onReceivedEventName, onReceivedPort, listener, ...)
	return self:AddTaskOnce(onReceivedEventName, onReceivedPort, Task(listener, ...))
end

---@async
---@param eventName Net.Core.EventName
---@param port Net.Core.Port
---@param timeoutSeconds number?
---@return Net.Core.NetworkContext?
function NetworkClient:WaitForEvent(eventName, port, timeoutSeconds)
	local result
	---@param context Net.Core.NetworkContext
	local function set(context)
		result = context
	end

	local netPort = self:AddListenerOnce(eventName, port, set)
	netPort:OpenPort()

	self.m_logger:LogDebug("waiting for event: '" .. eventName .. "' on port: " .. port)
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
	if self.m_networkCard:OpenPort(port) then
		self.m_logger:LogTrace('opened Port: ' .. port)
	end
end

---@param port integer
function NetworkClient:Close(port)
	self.m_networkCard:ClosePort(port)
	self.m_logger:LogTrace('closed Port: ' .. port)
end

function NetworkClient:CloseAll()
	self.m_networkCard:CloseAllPorts()
	self.m_logger:LogTrace('closed all Ports')
end

---@param ipAddress Net.Core.IPAddress
---@param port integer
---@param eventName string
---@param body any
---@param headers table<string, any>?
function NetworkClient:Send(ipAddress, port, eventName, body, headers)
	local jsonBody = self.m_serializer:Serialize(body)
	local jsonHeader = self.m_serializer:Serialize(headers)

	self.m_logger:LogTrace(
		"sending to '" .. ipAddress:GetAddress()
		.. "' on port: " .. port
		.. " with event: '" .. eventName .. "'")

	self.m_networkCard:Send(ipAddress:GetAddress(), port, eventName, jsonBody, jsonHeader)
end

---@param port integer
---@param eventName string
---@param body any
---@param header table<string, any>?
function NetworkClient:BroadCast(port, eventName, body, header)
	local jsonBody = self.m_serializer:Serialize(body)
	local jsonHeader = self.m_serializer:Serialize(header)

	self.m_logger:LogTrace("broadcast on port: " .. port .. " with event: '" .. eventName .. "'")

	self.m_networkCard:BroadCast(port, eventName, jsonBody, jsonHeader)
end

return Utils.Class.CreateClass(NetworkClient, 'Core.Net.NetworkClient')
