local Event = require('Core.Event.Event')

---@class Net.Core.NetworkPort : object
---@field Port integer | "all"
---@field private _Events Dictionary<string, Core.Event>
---@field private _NetClient Net.Core.NetworkClient
---@field private _Logger Core.Logger
---@overload fun(port: integer | "all", logger: Core.Logger, netClient: Net.Core.NetworkClient) : Net.Core.NetworkPort
local NetworkPort = {}

---@private
---@param port integer | "all"
---@param logger Core.Logger
---@param netClient Net.Core.NetworkClient
function NetworkPort:__init(port, logger, netClient)
	self.Port = port
	self._Events = {}
	self._Logger = logger
	self._NetClient = netClient
end

---@return Dictionary<string, Core.Event>
function NetworkPort:GetEvents()
	return Utils.Table.Copy(self._Events)
end

---@return integer
function NetworkPort:GetEventsCount()
	return Utils.Table.Count(self._Events)
end

---@return Net.Core.NetworkClient
function NetworkPort:GetNetClient()
	return self._NetClient
end

---@param context Net.Core.NetworkContext
function NetworkPort:Execute(context)
	self._Logger:LogTrace("got triggered with event: '" .. context.EventName .. "'")
	for name, event in pairs(self._Events) do
		if name == context.EventName or name == 'all' then
			event:Trigger(self._Logger, context)
		end
		if event:GetCount() == 0 then
			self._Events[name] = nil
		end
	end
end

---@protected
---@param eventName string | "all"
---@return Core.Event?
function NetworkPort:GetEvent(eventName)
	for name, event in pairs(self._Events) do
		if name == eventName then
			return event
		end
	end
end

---@protected
---@param eventName string | "all"
---@return Core.Event
function NetworkPort:CreateOrGetEvent(eventName)
	local event = self:GetEvent(eventName)
	if event then
		return event
	end

	event = Event()
	self._Events[eventName] = event
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

---@param onRecivedEventName string | "all"
---@param listener Core.Task
---@return Net.Core.NetworkPort
function NetworkPort:AddListenerOnce(onRecivedEventName, listener)
	local event = self:CreateOrGetEvent(onRecivedEventName)
	event:AddListenerOnce(listener)
	return self
end

---@param eventName string | "all"
function NetworkPort:RemoveListener(eventName)
	local event = self:GetEvent(eventName)
	if not event then
		return
	end

	self._Events[eventName] = nil
end

---@param eventName string
---@param timeoutSeconds number?
---@return Net.Core.NetworkContext?
function NetworkPort:WaitForEvent(eventName, timeoutSeconds)
	return self._NetClient:WaitForEvent(eventName, self.Port, timeoutSeconds)
end

function NetworkPort:OpenPort()
	local port = self.Port
	if type(port) == 'number' then
		self._NetClient:Open(port)
	end
end

function NetworkPort:ClosePort()
	local port = self.Port
	if type(port) == 'number' then
		self._NetClient:Close(port)
	end
end

---@param ipAddress Net.Core.IPAddress
---@param eventName string
---@param body any
---@param header Dictionary<string, any>?
function NetworkPort:SendMessage(ipAddress, eventName, body, header)
	local port = self.Port
	if port == 'all' then
		error('Unable to send a message over all ports')
	end
	---@cast port integer
	self._NetClient:Send(ipAddress, port, eventName, body, header)
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
	self._NetClient:BroadCast(port, eventName, body, header)
end

return Utils.Class.CreateClass(NetworkPort, 'Core.Net.NetworkPort')
