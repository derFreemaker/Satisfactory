local Task = require("Core.Common.Task")
local Event = require('Core.Event')

---@class Net.Core.NetworkPort : object
---@field Port Net.Core.Port
---@field private m_events table<string, Core.Event>
---@field private m_netClient Net.Core.NetworkClient
---@field private m_logger Core.Logger
---@overload fun(port: Net.Core.Port, logger: Core.Logger, netClient: Net.Core.NetworkClient) : Net.Core.NetworkPort
local NetworkPort = {}

---@private
---@param port Net.Core.Port
---@param logger Core.Logger
---@param netClient Net.Core.NetworkClient
function NetworkPort:__init(port, logger, netClient)
	self.Port = port
	self.m_events = {}
	self.m_logger = logger
	self.m_netClient = netClient
end

---@return table<string, Core.Event>
function NetworkPort:GetEvents()
	return Utils.Table.Copy(self.m_events)
end

---@return integer
function NetworkPort:GetEventsCount()
	return Utils.Table.Count(self.m_events)
end

---@return Net.Core.NetworkClient
function NetworkPort:GetNetClient()
	return self.m_netClient
end

---@param context Net.Core.NetworkContext
function NetworkPort:Execute(context)
	self.m_logger:LogTrace("got triggered with event: '" .. context.EventName .. "'")
	for name, event in pairs(self.m_events) do
		if name == context.EventName or name == 'all' then
			event:Trigger(self.m_logger, context)
		end
		if event:Count() == 0 then
			self:RemoveEvent(name)
		end
	end
end

---@protected
---@param eventName Net.Core.EventName
---@return Core.Event?
function NetworkPort:GetEvent(eventName)
	for name, event in pairs(self.m_events) do
		if name == eventName then
			return event
		end
	end
end

---@protected
---@param eventName Net.Core.EventName
---@return Core.Event
function NetworkPort:CreateOrGetEvent(eventName)
	local event = self:GetEvent(eventName)
	if event then
		return event
	end

	event = Event()
	self.m_events[eventName] = event
	return event
end

---@param onReceivedEventName Net.Core.EventName
---@param listener Core.Task
---@return number taskIndex
function NetworkPort:AddTask(onReceivedEventName, listener)
	local event = self:CreateOrGetEvent(onReceivedEventName)
	return event:AddTask(listener)
end

---@param onReceivedEventName Net.Core.EventName
---@param listener Core.Task
---@return number taskIndex
function NetworkPort:AddTaskOnce(onReceivedEventName, listener)
	local event = self:CreateOrGetEvent(onReceivedEventName)
	return event:AddTaskOnce(listener)
end

---@param eventName Net.Core.EventName
function NetworkPort:RemoveEvent(eventName)
	self.m_events[eventName] = nil
end

---@param eventName string
---@param taskIndex number
function NetworkPort:RemoveTask(eventName, taskIndex)
	local event = self:GetEvent(eventName)
	if not event then
		return
	end

	event:Remove(taskIndex)
end

---@param eventName string
---@param taskIndex number
function NetworkPort:RemoveTaskOnce(eventName, taskIndex)
	local event = self:GetEvent(eventName)
	if not event then
		return
	end

	event:RemoveOnce(taskIndex)
end

---@param eventName string
---@param timeoutSeconds number?
---@return Net.Core.NetworkContext?
function NetworkPort:WaitForEvent(eventName, timeoutSeconds)
	return self.m_netClient:WaitForEvent(eventName, self.Port, timeoutSeconds)
end

function NetworkPort:OpenPort()
	local port = self.Port
	if type(port) == 'number' then
		self.m_netClient:Open(port)
	end
end

function NetworkPort:ClosePort()
	local port = self.Port
	if type(port) == 'number' then
		self.m_netClient:Close(port)
	end
end

---@param ipAddress Net.Core.IPAddress
---@param eventName string
---@param body any
---@param header table<string, any>?
function NetworkPort:SendMessage(ipAddress, eventName, body, header)
	local port = self.Port
	if port == 'all' then
		error('Unable to send a message over all ports')
	end
	---@cast port integer
	self.m_netClient:Send(ipAddress, port, eventName, body, header)
end

---@param eventName string
---@param body any
---@param header table<string, any>?
function NetworkPort:BroadCastMessage(eventName, body, header)
	local port = self.Port
	if port == 'all' then
		error('Unable to broadcast a message over all ports')
	end
	---@cast port integer
	self.m_netClient:BroadCast(port, eventName, body, header)
end

return Utils.Class.Create(NetworkPort, 'Core.Net.NetworkPort')
