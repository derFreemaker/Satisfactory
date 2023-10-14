local Event = require('Core.Event.Event')

---@class Core.EventPullAdapter
---@field private events Dictionary<string, Core.Event>
---@field private logger Core.Logger
---@field OnEventPull Core.Event
local EventPullAdapter = {}

---@private
---@param eventPullData any[]
function EventPullAdapter:onEventPull(eventPullData)
	---@type string[]
	local removeEvent = {}
	for name, event in pairs(self.events) do
		if name == eventPullData[1] then
			event:Trigger(self.logger, eventPullData)
		end
		if #event == 0 then
			table.insert(removeEvent, name)
		end
	end
	for _, name in ipairs(removeEvent) do
		self.events[name] = nil
	end
end

---@param logger Core.Logger
---@return Core.EventPullAdapter
function EventPullAdapter:Initialize(logger)
	self.events = {}
	self.logger = logger
	self.OnEventPull = Event()
	return self
end

---@param signalName string
---@return Core.Event
function EventPullAdapter:GetEvent(signalName)
	for name, event in pairs(self.events) do
		if name == signalName then
			return event
		end
	end
	local event = Event()
	self.events[signalName] = event
	return event
end

---@param signalName string
---@param task Core.Task
function EventPullAdapter:AddListener(signalName, task)
	local event = self:GetEvent(signalName)
	event:AddListener(task)
	return self
end

---@param signalName string
---@param task Core.Task
function EventPullAdapter:AddListenerOnce(signalName, task)
	local event = self:GetEvent(signalName)
	event:AddListenerOnce(task)
	return self
end

---@param timeout number? in seconds
---@return boolean gotEvent
function EventPullAdapter:Wait(timeout)
	self.logger:LogTrace('## waiting for event pull ##')
	---@type table?
	local eventPullData = nil
	if timeout == nil then
		eventPullData = { event.pull() }
	else
		eventPullData = { event.pull(timeout) }
	end
	if #eventPullData == 0 then
		return false
	end
	self.logger:LogDebug("event with signalName: '" .. eventPullData[1] .. "' was recieved")
	self.OnEventPull:Trigger(self.logger, eventPullData)
	self:onEventPull(eventPullData)
	return true
end

--- Waits for all events in the event queue to be handled
---@param timeout number? in seconds
function EventPullAdapter:WaitForAll(timeout)
	while self:Wait(timeout) do
	end
end

--- Starts event pull loop
--- ## will never return
function EventPullAdapter:Run()
	self.logger:LogDebug('## started event pull loop ##')
	while true do
		self:Wait()
	end
end

return EventPullAdapter
