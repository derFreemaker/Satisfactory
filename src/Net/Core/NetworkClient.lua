local NetworkCardAdapter = require('Adapter.Computer.NetworkCard')
local Json = require('Core.Json')
local EventPullAdapter = require('Core.Event.EventPullAdapter')
local Task = require('Core.Task')
local NetworkPort = require('Net.Core.NetworkPort')
local NetworkContext = require('Net.Core.NetworkContext')

---@class Net.Core.NetworkClient : object
---@field private Logger Core.Logger
---@field private ports Dictionary<integer | "all", Net.Core.NetworkPort>
---@field private networkCard Adapter.Computer.NetworkCard
---@overload fun(logger: Core.Logger, networkCard: Adapter.Computer.NetworkCard?) : Net.Core.NetworkClient
local NetworkClient = {}

---@private
---@param logger Core.Logger
---@param networkCard Adapter.Computer.NetworkCard?
function NetworkClient:__init(logger, networkCard)
	networkCard = networkCard or NetworkCardAdapter(1)

	self.Logger = logger
	self.ports = {}
	self.networkCard = networkCard

	networkCard:Listen()
	EventPullAdapter:AddListener('NetworkMessage', Task(self.networkMessageRecieved, self))
end

---@private
---@param data any[]
function NetworkClient:networkMessageRecieved(data)
	local context = NetworkContext(data)
	self.Logger:LogDebug("recieved network message with event: '" .. context.EventName .. "' on port: '" .. context.Port .. "'")
	for i, port in pairs(self.ports) do
		if port.Port == context.Port or port.Port == 'all' then
			port:Execute(context)
		end
		if port:GetEventsCount() == 0 then
			port:ClosePort()
			self.ports[i] = nil
		end
	end
end

---@param port integer | "all"
---@return Net.Core.NetworkPort?
function NetworkClient:GetNetworkPort(port)
	for portNumber, networkPort in pairs(self.ports) do
		if portNumber == port then
			return networkPort
		end
	end
	return nil
end

---@param port integer | "all"
---@return Net.Core.NetworkPort
function NetworkClient:GetOrCreateNetworkPort(port)
	return self:GetNetworkPort(port) or self:CreateNetworkPort(port)
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
NetworkClient.On = NetworkClient.AddListener

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
NetworkClient.Once = NetworkClient.AddListenerOnce

---@param port (integer | "all")?
---@return Net.Core.NetworkPort
function NetworkClient:CreateNetworkPort(port)
	port = port or 'all'

	local networkPort = self:GetNetworkPort(port)
	if networkPort then
		return networkPort
	end

	networkPort = NetworkPort(port, self.Logger:subLogger('NetworkPort[' .. port .. ']'), self)
	self.ports[port] = networkPort
	return networkPort
end

---@param eventName string | "all"
---@param port integer | "all"
---@param timeout number?
---@return Net.Core.NetworkContext?
function NetworkClient:WaitForEvent(eventName, port, timeout)
	self.Logger:LogDebug("waiting for event: '" .. eventName .. "' on port: " .. port)
	local result
	---@param context Net.Core.NetworkContext
	local function set(context)
		result = context
	end
	self:AddListenerOnce(eventName, port, Task(set)):OpenPort()
	repeat
		if not EventPullAdapter:Wait(timeout) then
			break
		end
	until result ~= nil
	return result
end

---@param port integer
function NetworkClient:Open(port)
	self.networkCard:OpenPort(port)
	self.Logger:LogTrace('opened Port: ' .. port)
end

---@param port integer
function NetworkClient:Close(port)
	self.networkCard:ClosePort(port)
	self.Logger:LogTrace('closed Port: ' .. port)
end

function NetworkClient:CloseAll()
	self.networkCard:CloseAllPorts()
	self.Logger:LogTrace('closed all Ports')
end

---@param ipAddress string
---@param port integer
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkClient:Send(ipAddress, port, eventName, body, header)
	self.networkCard:Send(ipAddress, port, eventName, Json.encode(body), Json.encode(header or {}))
end

---@param port integer
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkClient:BroadCast(port, eventName, body, header)
	self.networkCard:BroadCast(port, eventName, Json.encode(body), Json.encode(header or {}))
end

return Utils.Class.CreateClass(NetworkClient, 'Core.Net.NetworkClient')
