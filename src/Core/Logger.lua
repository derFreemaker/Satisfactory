local Event = require('Core.Event.Event')

---@alias Core.Logger.LogLevel
---|0 Trace
---|1 Debug
---|2 Info
---|3 Warning
---|4 Error
---|10 Write

---@class Core.Logger : object
---@field OnLog Core.Event
---@field OnClear Core.Event
---@field Name string
---@field private _LogLevel Core.Logger.LogLevel
---@overload fun(name: string, logLevel: Core.Logger.LogLevel, onLog: Core.Event?, onClear: Core.Event?) : Core.Logger
local Logger = {}

---@param node table
---@param maxLevel number?
---@param properties string[]?
---@param level number?
---@param padding string?
---@return string[]
local function tableToLineTree(node, maxLevel, properties, level, padding)
	padding = padding or '     '
	maxLevel = maxLevel or 5
	level = level or 1
	local lines = {}

	if type(node) == 'table' then
		local keys = {}
		if type(properties) == 'string' then
			local propSet = {}
			for p in string.gmatch(properties, '%b{}') do
				local propName = string.sub(p, 2, -2)
				for k in string.gmatch(propName, '[^,%s]+') do
					propSet[k] = true
				end
			end
			for k in pairs(node) do
				if propSet[k] then
					keys[#keys + 1] = k
				end
			end
		else
			for k in pairs(node) do
				if not properties or properties[k] then
					keys[#keys + 1] = k
				end
			end
		end
		table.sort(keys)

		for i, k in ipairs(keys) do
			local line = ''
			if i == #keys then
				line = padding .. '└── ' .. tostring(k)
			else
				line = padding .. '├── ' .. tostring(k)
			end
			table.insert(lines, line)

			if level < maxLevel then
				---@cast properties string[]
				local childLines = tableToLineTree(node[k], maxLevel, properties, level + 1,
					padding .. (i == #keys and '    ' or '│   '))
				for _, l in ipairs(childLines) do
					table.insert(lines, l)
				end
			elseif i == #keys then
				table.insert(lines, padding .. '└── ...')
			end
		end
	else
		table.insert(lines, padding .. tostring(node))
	end

	return lines
end

---@private
---@param name string
---@param logLevel Core.Logger.LogLevel
---@param onLog Core.Event?
---@param onClear Core.Event?
function Logger:__init(name, logLevel, onLog, onClear)
	self._LogLevel = logLevel
	self.Name = (string.gsub(name, ' ', '_') or '')
	self.OnLog = onLog or Event()
	self.OnClear = onClear or Event()
end

---@param name string
---@return Core.Logger
function Logger:subLogger(name)
	name = self.Name .. '.' .. name
	local logger = Logger(name, self._LogLevel)
	return self:CopyListenersTo(logger)
end

---@param logger Core.Logger
---@return Core.Logger logger
function Logger:CopyListenersTo(logger)
	self.OnLog:CopyTo(logger.OnLog)
	self.OnClear:CopyTo(logger.OnClear)
	return logger
end

---@param message string
---@param logLevel Core.Logger.LogLevel
function Logger:Log(message, logLevel)
	if logLevel < self._LogLevel then
		return
	end

	message = '[' .. self.Name .. '] ' .. message
	self.OnLog:Trigger(nil, message)
end

---@param t table
---@param logLevel Core.Logger.LogLevel
---@param maxLevel integer?
---@param properties string[]?
function Logger:LogTable(t, logLevel, maxLevel, properties)
	if logLevel < self._LogLevel then
		return
	end

	if t == nil or type(t) ~= 'table' then
		return
	end
	for _, line in ipairs(tableToLineTree(t, maxLevel, properties)) do
		self:Log(line, logLevel)
	end
end

function Logger:Clear()
	self.OnClear:Trigger()
end

---@param logLevel Core.Logger.LogLevel
function Logger:FreeLine(logLevel)
	if logLevel < self._LogLevel then
		return
	end

	self.OnLog:Trigger(self, '')
end

---@param ... any
---@return string?
local function formatMessage(...)
	local messages = { ... }
	if #messages == 0 then
		return nil
	end
	local message = ""
	for i, arg in pairs(messages) do
		if i == 1 then
			message = tostring(arg) or "nil"
		else
			message = message .. "   " .. (tostring(arg) or "nil")
		end
	end
	return message
end

---@param ... any
function Logger:LogTrace(...)
	local message = formatMessage(...)
	if not message then
		return
	end

	self:Log('TRACE ' .. tostring(message), 0)
end

---@param ... any
function Logger:LogDebug(...)
	local message = formatMessage(...)
	if not message then
		return
	end

	self:Log('DEBUG ' .. tostring(message), 1)
end

---@param ... any
function Logger:LogInfo(...)
	local message = formatMessage(...)
	if not message then
		return
	end

	self:Log('INFO ' .. tostring(message), 2)
end

---@param ... any
function Logger:LogWarning(...)
	local message = formatMessage(...)
	if not message then
		return
	end

	self:Log('WARN ' .. tostring(message), 3)
end

---@param ... any
function Logger:LogError(...)
	local message = formatMessage(...)
	if not message then
		return
	end

	self:Log('ERROR ' .. tostring(message), 4)
end

return Utils.Class.CreateClass(Logger, 'Core.Logger')
