local Event = require('Core.Event.Event')

--- Assists in handling events from `event.pull()`
---
---@class Core.EventPullAdapter
---@field private _Initialized boolean
---@field private _Events Dictionary<string, Core.Event>
---@field private _Logger Core.Logger
---@field OnEventPull Core.Event
local EventPullAdapter = {}

---@private
---@param eventPullData any[]
function EventPullAdapter:onEventPull(eventPullData)
	---@type string[]
	local removeEvent = {}
	for name, event in pairs(self._Events) do
		if name == eventPullData[1] then
			event:Trigger(self._Logger, eventPullData)
		end
		if event:GetCount() == 0 then
			table.insert(removeEvent, name)
		end
	end
	for _, name in ipairs(removeEvent) do
		self._Events[name] = nil
	end
end

---@param logger Core.Logger
---@return Core.EventPullAdapter
function EventPullAdapter:Initialize(logger)
	if self._Initialized then
		return self
	end

	self._Events = {}
	self._Logger = logger
	self.OnEventPull = Event()
	self._Initialized = true

	return self
end

---@param signalName string
---@return Core.Event
function EventPullAdapter:GetEvent(signalName)
	for name, event in pairs(self._Events) do
		if name == signalName then
			return event
		end
	end
	local event = Event()
	self._Events[signalName] = event
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
	self._Logger:LogTrace('## waiting for event pull ##')
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

	self._Logger:LogDebug("event with signalName: '"
		.. eventPullData[1] .. "' was recieved from component: "
		.. tostring(eventPullData[2]))

	self.OnEventPull:Trigger(self._Logger, eventPullData)
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
	self._Logger:LogDebug('## started event pull loop ##')
	while true do
		self:Wait()
	end
end

return EventPullAdapter
