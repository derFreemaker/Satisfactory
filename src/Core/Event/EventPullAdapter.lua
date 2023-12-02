local Task = require("Core.Common.Task")
local Event = require('Core.Event.Event')

--- Assists in handling events from `event.pull()`
---
---@class Core.EventPullAdapter
---@field OnEventPull Core.Event
---@field private m_events table<string, Core.Event>
---@field private m_logger Core.Logger
local EventPullAdapter = {}

---@private
---@param eventPullData any[]
function EventPullAdapter:onEventPull(eventPullData)
	local eventName = eventPullData[1]
	local event = self.m_events[eventName]
	if not event then
		return
	end
	event:Trigger(self.m_logger, eventPullData)
	if event:Count() == 0 then
		self.m_events[eventName] = nil
	end
end

---@param logger Core.Logger
---@return Core.EventPullAdapter
function EventPullAdapter:Initialize(logger)
	self.m_events = {}
	self.m_logger = logger
	self.OnEventPull = Event()

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
---@return Core.EventPullAdapter
function EventPullAdapter:AddTask(signalName, task)
	local event = self:GetEvent(signalName)
	event:AddTask(task)
	return self
end

---@param signalName string
---@param task Core.Task
---@return Core.EventPullAdapter
function EventPullAdapter:AddTaskOnce(signalName, task)
	local event = self:GetEvent(signalName)
	event:AddTaskOnce(task)
	return self
end

---@param signalName string
---@param listener function
---@param ... any
---@return Core.EventPullAdapter
function EventPullAdapter:AddListener(signalName, listener, ...)
	return self:AddTask(signalName, Task(listener, ...))
end

---@param signalName string
---@param listener function
---@param ... any
---@return Core.EventPullAdapter
function EventPullAdapter:AddListenerOnce(signalName, listener, ...)
	return self:AddTaskOnce(signalName, Task(listener, ...))
end

--- Waits for an event to be handled or timeout
--- Returns true if event was handled and false if it timeout
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

--- Waits for all events in the event queue to be handled or timeout
---
---@async
---@param timeoutSeconds number?
function EventPullAdapter:WaitForAll(timeoutSeconds)
	while self:Wait(timeoutSeconds) do
	end
end

--- Starts event pull loop
--- ## will never return
---@async
function EventPullAdapter:Run()
	self.m_logger:LogDebug('## started event pull loop ##')
	while true do
		self:Wait()
	end
end

return EventPullAdapter
