local Event = require('Core.Event.Event')

---@class Net.Core.NetworkPort : object
---@field Port integer | "all"
---@field private events Dictionary<string, Core.Event>
---@field private netClient Net.Core.NetworkClient
---@field private logger Core.Logger
---@overload fun(port: integer | "all", logger: Core.Logger, netClient: Net.Core.NetworkClient) : Net.Core.NetworkPort
local NetworkPort = {}

---@private
---@param port integer | "all"
---@param logger Core.Logger
---@param netClient Net.Core.NetworkClient
function NetworkPort:__init(port, logger, netClient)
	self.Port = port
	self.events = {}
	self.logger = logger
	self.netClient = netClient
end

---@return Dictionary<string, Core.Event>
function NetworkPort:GetEvents()
	return Utils.Table.Copy(self.events)
end

---@return integer
function NetworkPort:GetEventsCount()
	return #self.events
end

---@return Net.Core.NetworkClient
function NetworkPort:GetNetClient()
	return self.netClient
end

---@param context Net.Core.NetworkContext
function NetworkPort:Execute(context)
	self.logger:LogTrace("got triggered with event: '" .. context.EventName .. "'")
	for name, event in pairs(self.events) do
		if name == context.EventName or name == 'all' then
			event:Trigger(self.logger, context)
		end
		if #event == 0 then
			self.events[name] = nil
		end
	end
end

---@protected
---@param eventName string | "all"
---@return Core.Event
function NetworkPort:CreateOrGetEvent(eventName)
	for name, event in pairs(self.events) do
		if name == eventName then
			return event
		end
	end
	local event = Event()
	self.events[eventName] = event
	return event
end

---@param onRecivedEventName string | "all"
---@param listener Core.Task
---@return Net.Core.NetworkPort
function NetworkPort:AddListener(onRecivedEventName, listener)
	local event = self:CreateOrGetEvent(onRecivedEventName)
	event:AddListener(listener)
	return self
end
NetworkPort.On = NetworkPort.AddListener

---@param onRecivedEventName string | "all"
---@param listener Core.Task
---@return Net.Core.NetworkPort
function NetworkPort:AddListenerOnce(onRecivedEventName, listener)
	local event = self:CreateOrGetEvent(onRecivedEventName)
	event:AddListenerOnce(listener)
	return self
end
NetworkPort.Once = NetworkPort.AddListenerOnce

---@param eventName string
---@param timeout number?
---@return Net.Core.NetworkContext?
function NetworkPort:WaitForEvent(eventName, timeout)
	return self.netClient:WaitForEvent(eventName, self.Port, timeout)
end

function NetworkPort:OpenPort()
	local port = self.Port
	if type(port) == 'number' then
		self.netClient:Open(port)
	end
end

function NetworkPort:ClosePort()
	local port = self.Port
	if type(port) == 'number' then
		self.netClient:Close(port)
	end
end

---@param ipAddress string
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkPort:SendMessage(ipAddress, eventName, body, header)
	local port = self.Port
	if port == 'all' then
		error('Unable to send a message over all ports')
	end
	---@cast port integer
	self.netClient:Send(ipAddress, port, eventName, body, header)
end

---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkPort:BroadCastMessage(eventName, body, header)
	local port = self.Port
	if port == 'all' then
		error('Unable to broadcast a message over all ports')
	end
	---@cast port integer
	self.netClient:BroadCast(port, eventName, body, header)
end

return Utils.Class.CreateClass(NetworkPort, 'Core.Net.NetworkPort')
