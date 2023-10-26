local Event = require('Core.Event.Event')

--- Assists in handling events from `event.pull()`
---
---@class Core.EventPullAdapter
---@field private m_initialized boolean
---@field private m_events table<string, Core.Event>
---@field private m_logger Core.Logger
---@field OnEventPull Core.Event
local EventPullAdapter = {}

---@private
---@param eventPullData any[]
function EventPullAdapter:onEventPull(eventPullData)
	---@type string[]
	local removeEvent = {}
	for name, event in pairs(self.m_events) do
		if name == eventPullData[1] then
			event:Trigger(self.m_logger, eventPullData)
		end
		if event:GetCount() == 0 then
			table.insert(removeEvent, name)
		end
	end
	for _, name in ipairs(removeEvent) do
		self.m_events[name] = nil
	end
end

---@param logger Core.Logger
---@return Core.EventPullAdapter
function EventPullAdapter:Initialize(logger)
	if self.m_initialized then
		return self
	end

	self.m_events = {}
	self.m_logger = logger
	self.OnEventPull = Event()
	self.m_initialized = true

	return self
end

---@param signalName string
---@return Core.Event
function EventPullAdapter:GetEvent(signalName)
	for name, event in pairs(self.m_events) do
		if name == signalName then
			return event
		end
	end
	local event = Event()
	self.m_events[signalName] = event
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

--- Waits for an event to be handled or timeout to run out
--- Returns true if event was handled and false if timeout ran out
---
---@async
---@param timeoutSeconds number?
---@return boolean gotEvent
function EventPullAdapter:Wait(timeoutSeconds)
	self.m_logger:LogTrace('## waiting for event pull ##')
	---@type table?
	local eventPullData = nil
	if timeoutSeconds == nil then
		eventPullData = { event.pull() }
	else
		eventPullData = { event.pull(timeoutSeconds) }
	end
	if #eventPullData == 0 then
		return false
	end

	self.m_logger:LogDebug("event with signalName: '"
		.. eventPullData[1] .. "' was recieved from component: "
		.. tostring(eventPullData[2]))

	self.OnEventPull:Trigger(self.m_logger, eventPullData)
	self:onEventPull(eventPullData)
	return true
end

--- Waits for all events in the event queue to be handled or timeout to run out
---
---@async
---@param timeoutSeconds number?
function EventPullAdapter:WaitForAll(timeoutSeconds)
	while self:Wait(timeoutSeconds) do
	end
end

--- Starts event pull loop
--- ## will never return
function EventPullAdapter:Run()
	self.m_logger:LogDebug('## started event pull loop ##')
	while true do
		self:Wait()
	end
end

return EventPullAdapter
