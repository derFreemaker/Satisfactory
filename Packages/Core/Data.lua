---@meta
local PackageData = {}

PackageData["CoreCommonLazyEventHandler"] = {
    Location = "Core.Common.LazyEventHandler",
    Namespace = "Core.Common.LazyEventHandler",
    IsRunnable = true,
    Data = [[
local Event = require("Core.Event.Event")

---@alias Core.LazyEventHandler.OnSetup fun(lazyEventHandler: Core.LazyEventHandler)
---@alias Core.LazyEventHandler.OnClose fun(lazyEventHandler: Core.LazyEventHandler)

---@class Core.LazyEventHandler : object
---@field private m_Event Core.Event
---@field private m_IsSetup boolean
---@field private m_OnSetup Core.LazyEventHandler.OnSetup?
---@field private m_OnClose Core.LazyEventHandler.OnClose?
---@overload fun(onSetup: Core.LazyEventHandler.OnSetup?, onClose: Core.LazyEventHandler.OnClose?) : Core.LazyEventHandler
local LazyEventHandler = {}

---@alias Core.LazyEventHandler.Constructor fun(onSetup: Core.LazyEventHandler.OnSetup?, onClose: Core.LazyEventHandler.OnClose?)

---@private
---@param onSetup Core.LazyEventHandler.OnSetup?
---@param onClose Core.LazyEventHandler.OnClose?
function LazyEventHandler:__init(onSetup, onClose)
    self.m_Event = Event()

    self.m_IsSetup = false
    self.m_OnSetup = onSetup
    self.m_OnClose = onClose
end

---@return integer count
function LazyEventHandler:Count()
    return self.m_Event:Count()
end

---@private
---@param onlyClose boolean?
function LazyEventHandler:Check(onlyClose)
    local count = self.m_Event:Count()

    if count > 0 and not self.m_IsSetup and self.m_OnSetup and not onlyClose then
        self.m_OnSetup(self)
        self.m_IsSetup = true
        return
    end

    if count == 0 and self.m_IsSetup and self.m_OnClose then
        self.m_OnClose(self)
        self.m_IsSetup = false
        return
    end
end

---@param task Core.Task
---@return Core.LazyEventHandler
function LazyEventHandler:AddTask(task)
    self.m_Event:AddTask(task)
    self:Check()
    return self
end

---@param task Core.Task
---@return Core.LazyEventHandler
function LazyEventHandler:AddTaskOnce(task)
    self.m_Event:AddTaskOnce(task)
    self:Check()
    return self
end

---@param func function
---@param ... any
---@return Core.LazyEventHandler
function LazyEventHandler:AddListener(func, ...)
    self.m_Event:AddListener(func, ...)
    self:Check()
    return self
end

---@param func function
---@param ... any
---@return Core.LazyEventHandler
function LazyEventHandler:AddListenerOnce(func, ...)
    self.m_Event:AddListenerOnce(func, ...)
    self:Check()
    return self
end

---@param logger Core.Logger?
---@param ... any
function LazyEventHandler:Trigger(logger, ...)
    self.m_Event:Trigger(logger, ...)
    self:Check(true)
end

return Utils.Class.CreateClass(LazyEventHandler, "Core.LazyEventHandler")
]]
}

PackageData["CoreCommonLogger"] = {
    Location = "Core.Common.Logger",
    Namespace = "Core.Common.Logger",
    IsRunnable = true,
    Data = [[
local Event = require('Core.Event.Event')

---@alias Core.Logger.LogLevel
---|1 Trace
---|2 Debug
---|3 Info
---|4 Warning
---|5 Error
---|6 Fatal
---|10 Write (like normal log, but with source of log call)

---@enum Core.Logger.LogLevel.ToName
local LogLevelToName = {
	[1] = "Trace",
	[2] = "Debug",
	[3] = "Info",
	[4] = "Warning",
	[5] = "Error",
	[6] = "Fatal",
	[10] = "Write"
}

---@class Core.Logger : object
---@field OnLog Core.Event
---@field OnClear Core.Event
---@field Name string
---@field private m_logLevel Core.Logger.LogLevel
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

	if type(node) == 'table' and not Utils.Class.IsClass(node) then
		local keys = {}
		if type(properties) == 'string' then
			local propSet = {}
			for p in string.gmatch(properties, '%b{}') do
				local propName = string.sub(p, 2, -2)
				for k in string.gmatch(propName, '[^,%s]+') do
					propSet[k] = true
				end
			end
			for k in next, node, nil do
				if propSet[k] then
					keys[#keys + 1] = k
				end
			end
		else
			for k in next, node, nil do
				if not properties or properties[k] then
					keys[#keys + 1] = k
				end
			end
		end

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
	self.m_logLevel = logLevel
	self.Name = (string.gsub(name, ' ', '_') or '')
	self.OnLog = onLog or Event()
	self.OnClear = onClear or Event()
end

---@param name string
---@return Core.Logger
function Logger:subLogger(name)
	name = self.Name .. '.' .. name
	local logger = Logger(name, self.m_logLevel)
	return self:CopyListenersTo(logger)
end

---@param logger Core.Logger
---@return Core.Logger logger
function Logger:CopyListenersTo(logger)
	self.OnLog:CopyTo(logger.OnLog)
	self.OnClear:CopyTo(logger.OnClear)
	return logger
end

---@param obj any
---@return string messagePart
local function formatMessagePart(obj)
	if obj == nil then
		return "nil"
	end

	if type(obj) == "table" then
		if Utils.Class.IsClass(obj) then
			return tostring(obj)
		end

		local str = tostring(obj)
		for _, line in ipairs(tableToLineTree(obj)) do
			str = str .. "\n" .. line
		end
		return str
	end

	return tostring(obj)
end

---@param ... any
---@return string?
local function formatMessage(...)
	local messages = { ... }
	if #messages == 0 then
		return
	end
	local message = ""
	for i, messagePart in pairs(messages) do
		if i == 1 then
			message = formatMessagePart(messagePart)
		else
			message = message .. "\n" .. formatMessagePart(messagePart)
		end
	end
	return message
end

---@param logLevel Core.Logger.LogLevel
---@param ... any
function Logger:Log(logLevel, ...)
	if logLevel < self.m_logLevel then
		return
	end

	local message = formatMessage(...)
	if not message then
		return
	end

	if logLevel ~= 10 then
		message = ({ computer.magicTime() })[2] .. " [" .. LogLevelToName[logLevel] .. "]: " .. self.Name .. "\n"
			.. "    " .. message:gsub("\n", "\n    ")
	else
		message = message:gsub("\n", "\n    "):gsub("\r", "\n")
	end
	self.OnLog:Trigger(nil, message)
end

---@param t table
---@param logLevel Core.Logger.LogLevel
---@param maxLevel integer?
---@param properties string[]?
function Logger:LogTable(t, logLevel, maxLevel, properties)
	if logLevel < self.m_logLevel then
		return
	end

	if t == nil or type(t) ~= 'table' then
		return
	end

	local str = ""
	for _, line in ipairs(tableToLineTree(t, maxLevel, properties)) do
		str = str .. "\n" .. line
	end
	self:Log(logLevel, str)
end

function Logger:Clear()
	self.OnClear:Trigger()
end

---@param logLevel Core.Logger.LogLevel
function Logger:FreeLine(logLevel)
	if logLevel < self.m_logLevel then
		return
	end

	self.OnLog:Trigger(self, '')
end

---@param ... any
function Logger:LogTrace(...)
	self:Log(1, ...)
end

---@param ... any
function Logger:LogDebug(...)
	self:Log(2, ...)
end

---@param ... any
function Logger:LogInfo(...)
	self:Log(3, ...)
end

---@param ... any
function Logger:LogWarning(...)
	self:Log(4, ...)
end

---@param ... any
function Logger:LogError(...)
	self:Log(5, ...)
end

function Logger:LogFatal(...)
	self:Log(6, ...)
end

function Logger:LogWrite(...)
	self:Log(10, ...)
end

return Utils.Class.CreateClass(Logger, 'Core.Logger')
]]
}

PackageData["CoreCommonTask"] = {
    Location = "Core.Common.Task",
    Namespace = "Core.Common.Task",
    IsRunnable = true,
    Data = [[
---@class Core.Task : object
---@field private m_func function
---@field private m_passthrough any[]
---@field private m_thread thread
---@field private m_closed boolean
---@field private m_success boolean
---@field private m_results any[]
---@field private m_error string?
---@field private m_traceback string?
---@overload fun(func: function, ...: any) : Core.Task
local Task = {}

---@private
---@param func function
---@param ... any
function Task:__init(func, ...)
    self.m_func = func

    local passthrough = { ... }
    local count = #passthrough
    if count > 16 then
        -- look into Execute function for more information
        error("cannot pass more than 16 arguments")
    end
    if count > 0 then
        self.m_passthrough = passthrough
    end

    self.m_closed = false
    self.m_success = true
    self.m_results = {}
end

---@return boolean
function Task:IsSuccess()
    return self.m_success
end

---@return any ... results
function Task:GetResults()
    return table.unpack(self.m_results)
end

---@return any[] results
function Task:GetResultsArray()
    return self.m_results
end

---@return string
function Task:GetTraceback()
    return self:Traceback()
end

---@param ... any parameters
---@return any ... results
function Task:Execute(...)
    ---@param ... any parameters
    local function invokeFunc(...)
        if self.m_passthrough ~= nil then
            -- //TODO: this has to change
            -- Having to do this is a bit annoying, but it's the only way to get the correct number of arguments
            -- example code that doesn't work for some reason:
            --
            -- local args = { "hi1", "hi2" }
            -- local args2 = { "hi3", "hi4" }
            -- function foo2(...)
            --     print(...)
            -- end
            -- foo2(table.unpack(args, 1, #args), table.unpack(args2, 1, #args2))
            --
            -- Output:
            -- hi1 hi3 hi4
            local count = #self.m_passthrough
            if count < 5 then
                if count == 1 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            ...
                        )
                    }
                elseif count == 2 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            ...
                        )
                    }
                elseif count == 3 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            ...
                        )
                    }
                elseif count == 4 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            ...
                        )
                    }
                end
            elseif count < 9 then
                if count == 5 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            ...
                        )
                    }
                elseif count == 6 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            ...
                        )
                    }
                elseif count == 7 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            ...
                        )
                    }
                elseif count == 8 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            ...
                        )
                    }
                end
            elseif count < 13 then
                if count == 9 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            ...
                        )
                    }
                elseif count == 10 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            self.m_passthrough[10],
                            ...
                        )
                    }
                elseif count == 11 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            self.m_passthrough[10],
                            self.m_passthrough[11],
                            ...
                        )
                    }
                elseif count == 12 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            self.m_passthrough[10],
                            self.m_passthrough[11],
                            self.m_passthrough[12],
                            ...
                        )
                    }
                end
            else
                if count == 13 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            self.m_passthrough[10],
                            self.m_passthrough[11],
                            self.m_passthrough[12],
                            self.m_passthrough[13],
                            ...
                        )
                    }
                elseif count == 14 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            self.m_passthrough[10],
                            self.m_passthrough[11],
                            self.m_passthrough[12],
                            self.m_passthrough[13],
                            self.m_passthrough[14],
                            ...
                        )
                    }
                elseif count == 15 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            self.m_passthrough[10],
                            self.m_passthrough[11],
                            self.m_passthrough[12],
                            self.m_passthrough[13],
                            self.m_passthrough[14],
                            self.m_passthrough[15],
                            ...
                        )
                    }
                elseif count == 16 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            self.m_passthrough[10],
                            self.m_passthrough[11],
                            self.m_passthrough[12],
                            self.m_passthrough[13],
                            self.m_passthrough[14],
                            self.m_passthrough[15],
                            self.m_passthrough[16],
                            ...
                        )
                    }
                end
            end
        else
            self.m_results = { self.m_func(...) }
        end
    end

    self.m_thread = coroutine.create(invokeFunc)
    self.m_closed = false
    self.m_traceback = nil

    self.m_success, self.m_error = coroutine.resume(self.m_thread, ...)
    return table.unpack(self.m_results)
end

---@private
function Task:CheckThreadState()
    local state = self:State()

    if state == "not created" then
        error("cannot resume a not started task")
    end

    if self.m_closed then
        error("cannot resume a closed task")
    end

    if state == "running" then
        error("cannot resume running task")
    end

    if state == "dead" then
        error("cannot resume dead task")
    end
end

---@param ... any parameters
---@return any ... results
function Task:Resume(...)
    self:CheckThreadState()
    self.m_success, self.m_error = coroutine.resume(self.m_thread, ...)
    return table.unpack(self.m_results)
end

function Task:Close()
    if self.m_closed then return end
    if not self.m_success then
        self:Traceback(false)
    end
    coroutine.close(self.m_thread)
    self.m_closed = true
end

---@private
---@param all boolean?
---@return string traceback
function Task:Traceback(all)
    if self.m_traceback ~= nil or self.m_closed then
        return self.m_traceback
    end
    self.m_traceback = debug.traceback(self.m_thread, self.m_error or "") .. "\n[THREAD START]"
    if all then
        self.m_traceback = self.m_traceback .. "\n" .. debug.traceback():sub(18)
    end
    return self.m_traceback
end

---@return "not created" | "dead" | "normal" | "running" | "suspended"
function Task:State()
    if self.m_thread == nil then
        return "not created"
    end
    return coroutine.status(self.m_thread);
end

---@param logger Core.Logger?
---@param all boolean?
function Task:LogError(logger, all)
    self:Close()
    if not self.m_success and logger then
        logger:LogError("Task [Error]:\n" .. self:Traceback(all))
    end
end

return Utils.Class.CreateClass(Task, "Core.Task")
]]
}

PackageData["CoreCommonUUID"] = {
    Location = "Core.Common.UUID",
    Namespace = "Core.Common.UUID",
    IsRunnable = true,
    Data = [[
local math = math
local string = string

---@class Core.UUID : Core.Json.Serializable
---@field private m_head number[]
---@field private m_body number[]
---@field private m_tail number[]
---@overload fun(head: number[], body: number[], tail: number[]) : Core.UUID
local UUID = {}

---@type integer
UUID.Static__GeneratedCount = 1

UUID.Static__TemplateRegex = ".+-.+-.+"

--- Replaces 'x' in template with random character.
---@param amount integer
---@return number[] char
local function generateRandomChars(amount)
    ---@type number[]
    local chars = {}
    for i = 1, amount, 1 do
        local j = math.random(1, 3)

        if j == 1 then
            chars[i] = math.random(48, 57)
        elseif j == 2 then
            chars[i] = math.random(65, 90)
        elseif j == 3 then
            chars[i] = math.random(97, 122)
        end
    end
    return chars
end

---@return Core.UUID
function UUID.Static__New()
    math.randomseed(math.floor(computer.time()) + UUID.Static__GeneratedCount)
    local head = generateRandomChars(6)
    local body = generateRandomChars(4)
    local tail = generateRandomChars(6)
    return UUID(head, body, tail)
end

local emptyHead = { 48, 48, 48, 48, 48, 48 }
local emptyBody = { 48, 48, 48, 48 }
local emptyTail = { 48, 48, 48, 48, 48, 48 }

---@return number[] head, number[] body, number[] tail
local function getEmptyData()
    return emptyHead, emptyBody, emptyTail
end

local emptyUUID = nil
---@return Core.UUID
function UUID.Static__Empty()
    if emptyUUID then
        return emptyUUID
    end

    emptyUUID = UUID(getEmptyData())

    return UUID.Static__Empty()
end

---@param str string
---@return integer[]
local function convertStringToCharArray(str)
    return { string.byte(str, 1, str:len()) }
end

---@return number[] head, number[] body, number[] tail
local function parse(str)
    local splitedStr = Utils.String.Split(str, "-")

    local head = convertStringToCharArray(splitedStr[1])
    local body = convertStringToCharArray(splitedStr[2])
    local tail = convertStringToCharArray(splitedStr[3])

    return head, body, tail
end

---@param str string
---@return Core.UUID?
function UUID.Static__Parse(str)
    if not str:find(UUID.Static__TemplateRegex) then
        return nil
    end

    return UUID(parse(str))
end

---@private
---@param headOrSring number[]
---@param body number[]
---@param tail number[]
function UUID:__init(headOrSring, body, tail)
    if type(headOrSring) == "string" then
        headOrSring, body, tail = parse(headOrSring)
    end

    self:Raw__ModifyBehavior({ DisableCustomIndexing = true })
    self.m_head = headOrSring
    self.m_body = body
    self.m_tail = tail
    self:Raw__ModifyBehavior({ DisableCustomIndexing = false })
end

---@param other Core.UUID
---@return boolean isSame
function UUID:Equals(other)
    for i, char in ipairs(self.m_head) do
        if char ~= other.m_head[i] then
            return false
        end
    end

    for i, char in ipairs(self.m_body) do
        if char ~= other.m_body[i] then
            return false
        end
    end

    for i, char in ipairs(self.m_tail) do
        if char ~= other.m_tail[i] then
            return false
        end
    end

    return true
end

---@return string str
function UUID:ToString()
    local str = ""

    for _, char in ipairs(self.m_head) do
        str = str .. string.char(char)
    end

    str = str .. "-"

    for _, char in ipairs(self.m_body) do
        str = str .. string.char(char)
    end

    str = str .. "-"

    for _, char in ipairs(self.m_tail) do
        str = str .. string.char(char)
    end

    return str
end

function UUID:Serialize()
    return self:ToString()
end

---@private
function UUID:__newindex()
    error("Core.UUID is completely read only", 3)
end

---@private
function UUID:__tostring()
    return self:ToString()
end

return Utils.Class.CreateClass(UUID, 'Core.UUID', require("Core.Json.Serializable"))
]]
}

PackageData["CoreEventEvent"] = {
    Location = "Core.Event.Event",
    Namespace = "Core.Event.Event",
    IsRunnable = true,
    Data = [[
local Task = require("Core.Common.Task")

---@class Core.Event : object
---@field private m_funcs Core.Task[]
---@field private m_onceFuncs Core.Task[]
---@overload fun() : Core.Event
local Event = {}

---@alias Core.Event.Constructor fun()

---@private
function Event:__init()
    self.m_funcs = {}
    self.m_onceFuncs = {}
end

---@return integer count
function Event:Count()
    return #self.m_funcs + #self.m_onceFuncs
end

---@param task Core.Task
---@return integer index
function Event:AddTask(task)
    table.insert(self.m_funcs, task)
    return #self.m_funcs
end

---@param task Core.Task
---@return integer index
function Event:AddTaskOnce(task)
    table.insert(self.m_onceFuncs, task)
    return #self.m_onceFuncs
end

---@param func function
---@param ... any
---@return integer index
function Event:AddListener(func, ...)
    return self:AddTask(Task(func, ...))
end

---@param func function
---@param ... any
---@return integer index
function Event:AddListenerOnce(func, ...)
    return self:AddTaskOnce(Task(func, ...))
end

---@param index integer
function Event:Remove(index)
    table.remove(self.m_funcs, index)
end

---@param index integer
function Event:RemoveOnce(index)
    table.remove(self.m_onceFuncs, index)
end

---@param logger Core.Logger?
---@param ... any
function Event:Trigger(logger, ...)
    for _, task in ipairs(self.m_funcs) do
        task:Execute(...)
        task:Close()
        task:LogError(logger)
    end

    for _, task in ipairs(self.m_onceFuncs) do
        task:Execute(...)
        task:Close()
        task:LogError(logger)
    end
    self.m_onceFuncs = {}
end

---@alias Core.Event.Mode
---|"Permanent"
---|"Once"

---@return table<Core.Event.Mode, Core.Task[]>
function Event:Listeners()
    ---@type Core.Task[]
    local permanentTask = {}
    for _, task in ipairs(self.m_funcs) do
        table.insert(permanentTask, task)
    end

    ---@type Core.Task[]
    local onceTask = {}
    for _, task in ipairs(self.m_onceFuncs) do
        table.insert(onceTask, task)
    end
    return {
        Permanent = permanentTask,
        Once = onceTask
    }
end

---@param event Core.Event
---@return Core.Event event
function Event:CopyTo(event)
    for _, listener in ipairs(self.m_funcs) do
        event:AddTask(listener)
    end
    for _, listener in ipairs(self.m_onceFuncs) do
        event:AddTaskOnce(listener)
    end
    return event
end

return Utils.Class.CreateClass(Event, "Core.Event")
]]
}

PackageData["CoreEventEventPullAdapter"] = {
    Location = "Core.Event.EventPullAdapter",
    Namespace = "Core.Event.EventPullAdapter",
    IsRunnable = true,
    Data = [[
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
	---@type string[]
	local removeEvent = {}
	for name, event in pairs(self.m_events) do
		if name == eventPullData[1] then
			event:Trigger(self.m_logger, eventPullData)
		end
		if event:Count() == 0 then
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
]]
}

PackageData["CoreFileSystemFile"] = {
    Location = "Core.FileSystem.File",
    Namespace = "Core.FileSystem.File",
    IsRunnable = true,
    Data = [[
local Path = require("Core.FileSystem.Path")

---@alias Core.FileSystem.File.OpenModes
---|"r" read only -> file stream can just read from file. If file doesn’t exist, will return nil
---|"w" write -> file stream can read and write creates the file if it doesn’t exist
---|"a" end of file -> file stream can read and write cursor is set to the end of file
---|"+r" truncate -> file stream can read and write all previous data in file gets dropped
---|"+a" append -> file stream can read the full file but can only write to the end of the existing file

---@class Core.FileSystem.File : object
---@field private m_path Core.FileSystem.Path
---@field private m_mode Core.FileSystem.File.OpenModes?
---@field private m_file FIN.Filesystem.File?
---@overload fun(path: string | Core.FileSystem.Path) : Core.FileSystem.File
local File = {}

---@param path Core.FileSystem.Path | string
---@param data string
function File.Static__WriteAll(path, data)
    if type(path) == "string" then
        path = Path(path)
    end

    if not filesystem.exists(path:GetParentFolder()) then
        error("parent folder does not exist: " .. path:GetParentFolder())
    end

    local file = filesystem.open(path:GetPath(), "w")
    file:write(data)
    file:close()
end

---@param path Core.FileSystem.Path | string
---@return string
function File.Static__ReadAll(path)
    if type(path) == "string" then
        path = Path(path)
    end

    if not filesystem.exists(path:GetPath()) then
        error("file does not exist: " .. path:GetParentFolder())
    end

    local file = filesystem.open(path:GetPath(), "r")

    local str = ""
    while true do
        local buf = file:read(8192)
        if not buf then
            break
        end
        str = str .. buf
    end

    file:close()
    return str
end

---@private
---@param path string | Core.FileSystem.Path
function File:__init(path)
    if type(path) == "string" then
        self.m_path = Path(path)
        return
    end

    self.m_path = path
end

---@return string
function File:GetPath()
    return self.m_path:GetPath()
end

---@return boolean exists
function File:Exists()
    return filesystem.exists(self.m_path:GetPath())
end

---@return boolean isOpen
---@nodiscard
function File:IsOpen()
    if not self.m_file then
        return false
    end

    return true
end

---@private
function File:CheckState()
    if not self:IsOpen() then
        error("file is not open: " .. self.m_path:GetPath(), 3)
    end
end

---@param mode Core.FileSystem.File.OpenModes
---@return boolean isOpen
---@nodiscard
function File:Open(mode)
    local file

    if not filesystem.exists(self.m_path:GetPath()) then
        local parentFolder = self.m_path:GetParentFolder()
        if not filesystem.exists(parentFolder) then
            error("parent folder does not exist: " .. parentFolder)
        end

        if mode == "r" then
            file = filesystem.open(self.m_path:GetPath(), "w")
            file:write("")
            file:close()
            file = nil
        end

        return false
    end

    self.m_file = filesystem.open(self.m_path:GetPath(), mode)
    self.m_mode = mode

    return true
end

---@param data string
function File:Write(data)
    self:CheckState()

    self.m_file:write(data)
end

---@param length integer
function File:Read(length)
    self:CheckState()

    return self.m_file:read(length)
end

---@param offset integer
function File:Seek(offset)
    self:CheckState()

    self.m_file:seek(offset)
end

function File:Close()
    self.m_file:close()
    self.m_file = nil
end

function File:Clear()
    local isOpen = self:IsOpen()
    if isOpen then
        self:Close()
    end

    if not filesystem.exists(self.m_path:GetPath()) then
        return
    end

    filesystem.remove(self.m_path:GetPath())

    local file = filesystem.open(self.m_path:GetPath(), "w")
    file:write("")
    file:close()

    if isOpen then
        self.m_file = filesystem.open(self.m_path:GetPath(), self.m_mode)
    end
end

return Utils.Class.CreateClass(File, "Core.FileSystem.File")
]]
}

PackageData["CoreFileSystemPath"] = {
    Location = "Core.FileSystem.Path",
    Namespace = "Core.FileSystem.Path",
    IsRunnable = true,
    Data = [[
---@param str string
---@return string str
local function formatStr(str)
    str = str:gsub("\\", "/")
    return str
end

---@class Core.FileSystem.Path
---@field private m_nodes string[]
---@overload fun(pathOrNodes: (string | string[])?) : Core.FileSystem.Path
local Path = {}

---@param str string
---@return boolean isNode
function Path.Static__IsNode(str)
    if str:find("/") then
        return false
    end

    return true
end

---@private
---@param pathOrNodes string | string[]
function Path:__init(pathOrNodes)
    if not pathOrNodes then
        self.m_nodes = {}
        return
    end

    if type(pathOrNodes) == "string" then
        pathOrNodes = formatStr(pathOrNodes)
        pathOrNodes = Utils.String.Split(pathOrNodes, "/")
    end

    local lenght = #pathOrNodes
    local node = pathOrNodes[lenght]
    if node ~= "" and not node:find("^.+%..*$") and node:find(".+") then
        pathOrNodes[lenght] = ""
    end

    self.m_nodes = pathOrNodes

    self:Normalize()
end

---@return string path
function Path:GetPath()
    return Utils.String.Join(self.m_nodes, "/")
end

---@private
Path.__tostring = Path.GetPath

---@return boolean
function Path:IsEmpty()
    return #self.m_nodes == 0 or (#self.m_nodes == 2 and self.m_nodes[1] == "" and self.m_nodes[2] == "")
end

---@return boolean
function Path:IsFile()
    return self.m_nodes[#self.m_nodes] ~= ""
end

---@return boolean
function Path:IsDir()
    return self.m_nodes[#self.m_nodes] == ""
end

---@return string
function Path:GetParentFolder()
    local copy = Utils.Table.Copy(self.m_nodes)
    local lenght = #copy

    if lenght > 0 then
        if lenght > 1 and copy[lenght] == "" then
            copy[lenght] = nil
            copy[lenght - 1] = ""
        else
            copy[lenght] = nil
        end
    end

    return Utils.String.Join(copy, "/")
end

---@return Core.FileSystem.Path
function Path:GetParentFolderPath()
    local copy = self:Copy()
    local lenght = #copy.m_nodes

    if lenght > 0 then
        if lenght > 1 and copy.m_nodes[lenght] == "" then
            copy.m_nodes[lenght] = nil
            copy.m_nodes[lenght - 1] = ""
        else
            copy.m_nodes[lenght] = nil
        end
    end

    return copy
end

---@return string fileName
function Path:GetFileName()
    if not self:IsFile() then
        error("path is not a file: " .. self:GetPath())
    end

    return self.m_nodes[#self.m_nodes]
end

---@return string fileExtension
function Path:GetFileExtension()
    if not self:IsFile() then
        error("path is not a file: " .. self:GetPath())
    end

    local fileName = self.m_nodes[#self.m_nodes]

    local _, _, extension = fileName:find("^.+(%..+)$")
    return extension
end

---@return string fileStem
function Path:GetFileStem()
    if not self:IsFile() then
        error("path is not a file: " .. self:GetPath())
    end

    local fileName = self.m_nodes[#self.m_nodes]

    local _, _, stem = fileName:find("^(.+)%..+$")
    return stem
end

---@return Core.FileSystem.Path
function Path:Normalize()
    ---@type string[]
    local newNodes = {}

    for index, value in ipairs(self.m_nodes) do
        if value == "." then
        elseif value == "" then
            if index == 1 or index == #self.m_nodes then
                newNodes[#newNodes + 1] = ""
            end
        elseif value == ".." then
            if index ~= 1 then
                newNodes[#newNodes] = nil
            end
        else
            newNodes[#newNodes + 1] = value
        end
    end

    self.m_nodes = newNodes
    return self
end

---@param path string
---@return Core.FileSystem.Path
function Path:Append(path)
    path = formatStr(path)
    local newNodes = Utils.String.Split(path, "/")

    for _, value in ipairs(newNodes) do
        self.m_nodes[#self.m_nodes + 1] = value
    end

    self:Normalize()

    return self
end

---@param path string
---@return Core.FileSystem.Path
function Path:Extend(path)
    local copy = self:Copy()
    return copy:Append(path)
end

---@return Core.FileSystem.Path
function Path:Copy()
    local copyNodes = Utils.Table.Copy(self.m_nodes)
    return Path(copyNodes)
end

return Utils.Class.CreateClass(Path, "Core.Path")
]]
}

PackageData["CoreJsonJson"] = {
    Location = "Core.Json.Json",
    Namespace = "Core.Json.Json",
    IsRunnable = true,
    Data = [[
--
-- json.lua
--
-- Copyright (c) 2020 rxi
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

---@class Core.Json
local json = { _version = '0.1.2' }

-------------------------------------------------------------------------------
-- Encode
-------------------------------------------------------------------------------

local encode

local escape_char_map = {
	['\\'] = '\\',
	['"'] = '"',
	['\b'] = 'b',
	['\f'] = 'f',
	['\n'] = 'n',
	['\r'] = 'r',
	['\t'] = 't'
}

local escape_char_map_inv = { ['/'] = '/' }
for k, v in pairs(escape_char_map) do
	escape_char_map_inv[v] = k
end

local function escape_char(c)
	return '\\' .. (escape_char_map[c] or string.format('u%04x', c:byte()))
end

local function encode_nil(val)
	return 'null'
end

local function encode_table(val, stack)
	local res = {}
	stack = stack or {}

	-- Circular reference?
	if stack[val] then
		error('circular reference')
	end

	stack[val] = true

	if rawget(val, 1) ~= nil or next(val) == nil then
		-- Treat as array -- check keys are valid and it is not sparse
		local n = 0
		for k in pairs(val) do
			if type(k) ~= 'number' then
				error('invalid table: mixed or invalid key types')
			end
			n = n + 1
		end
		if n ~= #val then
			error('invalid table: sparse array')
		end
		-- Encode
		for i, v in ipairs(val) do
			table.insert(res, encode(v, stack))
		end
		stack[val] = nil
		return '[' .. table.concat(res, ',') .. ']'
	else
		-- Treat as an object
		for k, v in pairs(val) do
			if type(k) ~= 'string' then
				error('invalid table: mixed or invalid key types')
			end
			table.insert(res, encode(k, stack) .. ':' .. encode(v, stack))
		end
		stack[val] = nil
		return '{' .. table.concat(res, ',') .. '}'
	end
end

local function encode_string(val)
	return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
end

local function encode_number(val)
	-- Check for NaN, -inf and inf
	if val ~= val or val <= -math.huge or val >= math.huge then
		error("unexpected number value '" .. tostring(val) .. "'")
	end
	return string.format('%.14g', val)
end

---@alias Json.SerializeableTypes
---|nil
---|boolean
---|number
---|string
---|table

json.type_func_map = {
	['nil'] = encode_nil,
	['table'] = encode_table,
	['string'] = encode_string,
	['number'] = encode_number,
	['boolean'] = tostring
}

encode = function(val, stack)
	local t = type(val)
	local f = json.type_func_map[t]
	if f then
		return f(val, stack)
	end
	error("unexpected type '" .. t .. "'")
end

---@param val table
---@return string
function json.encode(val)
	return (encode(val))
end

-------------------------------------------------------------------------------
-- Decode
-------------------------------------------------------------------------------

local parse

local function create_set(...)
	local res = {}
	for i = 1, select('#', ...) do
		res[select(i, ...)] = true
	end
	return res
end

local space_chars = create_set(' ', '\t', '\r', '\n')
local delim_chars = create_set(' ', '\t', '\r', '\n', ']', '}', ',')
local escape_chars = create_set('\\', '/', '"', 'b', 'f', 'n', 'r', 't', 'u')
local literals = create_set('true', 'false', 'null')

local literal_map = {
	['true'] = true,
	['false'] = false,
	['null'] = nil
}

local function next_char(str, idx, set, negate)
	for i = idx, #str do
		if set[str:sub(i, i)] ~= negate then
			return i
		end
	end
	return #str + 1
end

local function decode_error(str, idx, msg)
	local line_count = 1
	local col_count = 1
	for i = 1, idx - 1 do
		col_count = col_count + 1
		if str:sub(i, i) == '\n' then
			line_count = line_count + 1
			col_count = 1
		end
	end
	error(string.format('%s at line %d col %d', msg, line_count, col_count))
end

local function codepoint_to_utf8(n)
	-- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
	local f = math.floor
	if n <= 0x7f then
		return string.char(n)
	elseif n <= 0x7ff then
		return string.char(f(n / 64) + 192, n % 64 + 128)
	elseif n <= 0xffff then
		return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
	elseif n <= 0x10ffff then
		return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128, f(n % 4096 / 64) + 128, n % 64 + 128)
	end
	error(string.format("invalid unicode codepoint '%x'", n))
end

local function parse_unicode_escape(s)
	local n1 = tonumber(s:sub(1, 4), 16)
	local n2 = tonumber(s:sub(7, 10), 16)
	-- Surrogate pair?
	if n2 then
		return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
	else
		return codepoint_to_utf8(n1)
	end
end

local function parse_string(str, i)
	local res = ''
	local j = i + 1
	local k = j

	while j <= #str do
		local x = str:byte(j)

		if x < 32 then
			decode_error(str, j, 'control character in string')
		elseif x == 92 then -- `\`: Escape
			res = res .. str:sub(k, j - 1)
			j = j + 1
			local c = str:sub(j, j)
			if c == 'u' then
				local hex = str:match('^[dD][89aAbB]%x%x\\u%x%x%x%x', j + 1) or str:match('^%x%x%x%x', j + 1) or
					decode_error(str, j - 1, 'invalid unicode escape in string')
				res = res .. parse_unicode_escape(hex)
				j = j + #hex
			else
				if not escape_chars[c] then
					decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
				end
				res = res .. escape_char_map_inv[c]
			end
			k = j + 1
		elseif x == 34 then -- `"`: End of string
			res = res .. str:sub(k, j - 1)
			return res, j + 1
		end

		j = j + 1
	end

	decode_error(str, i, 'expected closing quote for string')
end

local function parse_number(str, i)
	local x = next_char(str, i, delim_chars)
	local s = str:sub(i, x - 1)
	local n = tonumber(s)
	if not n then
		decode_error(str, i, "invalid number '" .. s .. "'")
	end
	return n, x
end

local function parse_literal(str, i)
	local x = next_char(str, i, delim_chars)
	local word = str:sub(i, x - 1)
	if not literals[word] then
		decode_error(str, i, "invalid literal '" .. word .. "'")
	end
	return literal_map[word], x
end

local function parse_array(str, i)
	local res = {}
	local n = 1
	i = i + 1
	while 1 do
		local x
		i = next_char(str, i, space_chars, true)
		-- Empty / end of array?
		if str:sub(i, i) == ']' then
			i = i + 1
			break
		end
		-- Read token
		x,
		i = parse(str, i)
		res[n] = x
		n = n + 1
		-- Next token
		i = next_char(str, i, space_chars, true)
		local chr = str:sub(i, i)
		i = i + 1
		if chr == ']' then
			break
		end
		if chr ~= ',' then
			decode_error(str, i, "expected ']' or ','")
		end
	end
	return res, i
end

local function parse_object(str, i)
	local res = {}
	i = i + 1
	while 1 do
		local key,
		val
		i = next_char(str, i, space_chars, true)
		-- Empty / end of object?
		if str:sub(i, i) == '}' then
			i = i + 1
			break
		end
		-- Read key
		if str:sub(i, i) ~= '"' then
			decode_error(str, i, 'expected string for key')
		end
		key,
		i = parse(str, i)
		-- Read ':' delimiter
		i = next_char(str, i, space_chars, true)
		if str:sub(i, i) ~= ':' then
			decode_error(str, i, "expected ':' after key")
		end
		i = next_char(str, i + 1, space_chars, true)
		-- Read value
		val,
		i = parse(str, i)
		-- Set
		res[key] = val
		-- Next token
		i = next_char(str, i, space_chars, true)
		local chr = str:sub(i, i)
		i = i + 1
		if chr == '}' then
			break
		end
		if chr ~= ',' then
			decode_error(str, i, "expected '}' or ','")
		end
	end
	return res, i
end

local char_func_map = {
	['"'] = parse_string,
	['0'] = parse_number,
	['1'] = parse_number,
	['2'] = parse_number,
	['3'] = parse_number,
	['4'] = parse_number,
	['5'] = parse_number,
	['6'] = parse_number,
	['7'] = parse_number,
	['8'] = parse_number,
	['9'] = parse_number,
	['-'] = parse_number,
	['t'] = parse_literal,
	['f'] = parse_literal,
	['n'] = parse_literal,
	['['] = parse_array,
	['{'] = parse_object
}

parse = function(str, idx)
	local chr = str:sub(idx, idx)
	local f = char_func_map[chr]
	if f then
		return f(str, idx)
	end
	decode_error(str, idx, "unexpected character '" .. chr .. "'")
end

---@param str string
---@return table
function json.decode(str)
	if type(str) ~= 'string' then
		error('expected argument of type string, got ' .. type(str))
	end
	local res,
	idx = parse(str, next_char(str, 1, space_chars, true))
	idx = next_char(str, idx, space_chars, true)
	if idx <= #str then
		decode_error(str, idx, 'trailing garbage')
	end
	return res
end

return json
]]
}

PackageData["CoreJsonJsonSerializer"] = {
    Location = "Core.Json.JsonSerializer",
    Namespace = "Core.Json.JsonSerializer",
    IsRunnable = true,
    Data = [[
local Json = require("Core.Json.Json")

---@class Core.Json.Serializer
---@field private m_typeInfos table<string, Utils.Class.Type>
---@overload fun(typeInfos: Utils.Class.Type[]?) : Core.Json.Serializer
local JsonSerializer = {}

---@type Core.Json.Serializer
JsonSerializer.Static__Serializer = Utils.Class.Placeholder

---@private
---@param typeInfos Utils.Class.Type[]?
function JsonSerializer:__init(typeInfos)
    self.m_typeInfos = {}

    for _, typeInfo in ipairs(typeInfos or {}) do
        self.m_typeInfos[typeInfo.Name] = typeInfo
    end
end

function JsonSerializer:AddTypesFromStatic()
    for name, typeInfo in pairs(self.Static__Serializer.m_typeInfos) do
        if not Utils.Table.ContainsKey(self.m_typeInfos, name) then
            self.m_typeInfos[name] = typeInfo
        end
    end
end

---@param typeInfo Utils.Class.Type
---@return Core.Json.Serializer
function JsonSerializer:AddTypeInfo(typeInfo)
    if not Utils.Class.HasTypeBaseClass("Core.Json.Serializable", typeInfo) then
        error("class type has not Core.Json.Serializable as base class", 2)
    end
    if not Utils.Table.ContainsKey(self.m_typeInfos, typeInfo.Name) then
        self.m_typeInfos[typeInfo.Name] = typeInfo
    end
    return self
end

---@param typeInfos Utils.Class.Type[]
---@return Core.Json.Serializer
function JsonSerializer:AddTypeInfos(typeInfos)
    for _, typeInfo in ipairs(typeInfos) do
        self:AddTypeInfo(typeInfo)
    end
    return self
end

---@param class object
---@return Core.Json.Serializer
function JsonSerializer:AddClass(class)
    return self:AddTypeInfo(typeof(class))
end

---@param classes object[]
---@return Core.Json.Serializer
function JsonSerializer:AddClasses(classes)
    for _, class in ipairs(classes) do
        self:AddClass(class)
    end
    return self
end

---@private
---@param class Core.Json.Serializable
---@return table data
function JsonSerializer:serializeClass(class)
    local typeInfo = typeof(class)
    local data = { __Type = typeInfo.Name, __Data = { class:Serialize() } }

    local max = 0
    for key, value in next, data.__Data, nil do
        if key > max then
            max = key
        end
    end

    for i = 1, max, 1 do
        if data.__Data[i] == nil then
            data.__Data[i] = "%nil%"
        end
    end

    if type(data.__Data) == "table" then
        for key, value in next, data.__Data, nil do
            data.__Data[key] = self:serializeInternal(value)
        end
    end

    return data
end

---@private
---@param obj any
---@return table data
function JsonSerializer:serializeInternal(obj)
    local objType = type(obj)
    if objType ~= "table" then
        if not Utils.Table.ContainsKey(Json.type_func_map, objType) then
            error("can not serialize: " .. objType .. " value: " .. tostring(obj))
            return {}
        end

        return obj
    end

    if Utils.Class.HasBaseClass(obj, "Core.Json.Serializable") then
        ---@cast obj Core.Json.Serializable
        return self:serializeClass(obj)
    end

    for key, value in next, obj, nil do
        if type(value) == "table" then
            rawset(obj, key, self:serializeInternal(value))
        end
    end

    return obj
end

---@param obj any
---@return string str
function JsonSerializer:Serialize(obj)
    return Json.encode(self:serializeInternal(obj))
end

---@private
---@param t table
---@return boolean isDeserializedClass
local function isDeserializedClass(t)
    if not t.__Type then
        return false
    end

    if not t.__Data then
        return false
    end

    return true
end

---@private
---@param t table
---@return object class
function JsonSerializer:deserializeClass(t)
    local data = t.__Data

    local typeInfo = self.m_typeInfos[t.__Type]
    if not typeInfo then
        error("unable to find typeInfo for class: " .. t.__Type)
    end

    ---@type Core.Json.Serializable
    local classTemplate = typeInfo.Template

    if type(data) == "table" then
        for key, value in next, data, nil do
            if value == "%nil%" then
                data[key] = nil
            end

            if type(value) == "table" then
                data[key] = self:deserializeInternal(value)
            end
        end
    end

    return classTemplate:Static__Deserialize(table.unpack(data))
end

---@private
---@param t table
---@return any obj
function JsonSerializer:deserializeInternal(t)
    if isDeserializedClass(t) then
        return self:deserializeClass(t)
    end

    for key, value in next, t, nil do
        if type(value) == "table" then
            t[key] = self:deserializeInternal(value)
        end
    end

    return t
end

---@param str string
---@return any obj
function JsonSerializer:Deserialize(str)
    local obj = Json.decode(str)

    if type(obj) == "table" then
        return self:deserializeInternal(obj)
    end

    return obj
end

---@param str string
---@param outObj Out<any>
---@return boolean couldDeserialize
function JsonSerializer:TryDeserialize(str, outObj)
    local success, _, results = Utils.Function.InvokeProtected(self.Deserialize, self, str)
    outObj.Value = results[1]

    return success
end

Utils.Class.CreateClass(JsonSerializer, "Core.Json.JsonSerializer")

JsonSerializer.Static__Serializer = JsonSerializer()
JsonSerializer.Static__Serializer:AddClass(require("Core.Common.UUID"))

return JsonSerializer
]]
}

PackageData["CoreJsonSerializable"] = {
    Location = "Core.Json.Serializable",
    Namespace = "Core.Json.Serializable",
    IsRunnable = true,
    Data = [[
---@alias Core.Json.Serializable.Types
---| string
---| number
---| boolean
---| table
---| Core.Json.Serializable

---@class Core.Json.Serializable : object
local Serializable = {}

---@return any ...
function Serializable:Serialize()
    local typeInfo = typeof(self)
    error("Serialize function was not override for type " .. typeInfo.Name)
end

---@param ... any
---@return any obj
function Serializable:Static__Deserialize(...)
    return self(...)
end

return Utils.Class.CreateClass(Serializable, "Core.Json.Serializable")
]]
}

PackageData["CoreReferencesIReference"] = {
    Location = "Core.References.IReference",
    Namespace = "Core.References.IReference",
    IsRunnable = true,
    Data = [[
---@class Core.IReference<T> : object, { Get: fun() : T }
---@field protected m_obj Satisfactory.Components.Object?
local IReference = {}

---@private
function IReference:__gc()
    log("__gc called on reference")
    self.m_obj = nil
end

---@return Satisfactory.Components.Object
function IReference:Get()
    self:Check()

    return self.m_obj
end

---@return boolean isValid
function IReference:IsValid()
    if not self.m_obj then
        return false
    end

    log("trying to see if reference is valid")
    local success = Utils.Function.InvokeProtected(function(obj) local _ = obj.hash end, self.m_obj)
    log("reference is valid: " .. tostring(success))

    return success
end

---@return boolean found
function IReference:Refresh()
    error("cannot call abstract method IReference:Refresh")
end

function IReference:Check()
    if not self:IsValid() then
        if not self:Refresh() then
            error("could not be refreshed", 2)
        elseif not self:IsValid() then
            error("not valid after refresh", 2)
        end
    end
end

return Utils.Class.CreateClass(IReference, "Core.IReference")
]]
}

PackageData["CoreReferencesPCIDeviceReference"] = {
    Location = "Core.References.PCIDeviceReference",
    Namespace = "Core.References.PCIDeviceReference",
    IsRunnable = true,
    Data = [[
---@class Core.PCIDeviceReference<T> : Core.IReference<T>
---@field m_class FIN.Class
---@field m_index integer
---@overload fun(class: FIN.Class, index: integer) : Core.PCIDeviceReference
local PCIDeviceReference = {}

---@private
---@param class FIN.Class
---@param index integer
function PCIDeviceReference:__init(class, index)
    self.m_class = class
    self.m_index = index
end

---@return boolean notFound
function PCIDeviceReference:Refresh()
    self.m_obj = computer.getPCIDevices(self.m_class)[self.m_index]
    return self.m_obj ~= nil
end

return Utils.Class.CreateClass(PCIDeviceReference, "Core.PCIDeviceReference",
    require("Core.References.IReference"))
]]
}

PackageData["CoreReferencesReference"] = {
    Location = "Core.References.Reference",
    Namespace = "Core.References.Reference",
    IsRunnable = true,
    Data = [[
---@class Core.Reference<T> : Core.IReference<T>
---@field m_id FIN.UUID
---@overload fun(id: FIN.UUID) : Core.Reference
local Reference = {}

---@private
---@param id FIN.UUID
function Reference:__init(id)
    self.m_id = id
end

---@return boolean found
function Reference:Refresh()
    self.m_obj = component.proxy(self.m_id)
    return component ~= nil
end

return Utils.Class.CreateClass(Reference, "Core.Reference",
    require("Core.References.IReference"))
]]
}

PackageData["CoreUsageinit"] = {
    Location = "Core.Usage.init",
    Namespace = "Core.Usage.init",
    IsRunnable = true,
    Data = [[
return {
    Ports = require("Core.Usage.Usage_Port"),
    Events = require("Core.Usage.Usage_EventName")
}
]]
}

PackageData["CoreUsageUsage_EventName"] = {
    Location = "Core.Usage.Usage_EventName",
    Namespace = "Core.Usage.Usage_EventName",
    IsRunnable = true,
    Data = [[
---@enum Core.EventNameUsage
local EventNameUsage = {
    -- DNS
    DNS_Heartbeat = "DNS",
    DNS_GetServerAddress = "Get-DNS-Server-Address",
    DNS_ReturnServerAddress = "Return-DNS-Server-Address",

    -- Rest
    RestRequest = "Rest-Request",
    RestResponse = "Rest-Response",

    -- FactoryControl
    FactoryControl_Heartbeat = "FactoryControl",
    FactoryControl_Feature_Update = "FactoryControl-Feature-Update",

    -- CallbackService
    CallbackService = "CallbackService",
    CallbackService_Response = "CallbackService-Response"
}

return EventNameUsage
]]
}

PackageData["CoreUsageUsage_Port"] = {
    Location = "Core.Usage.Usage_Port",
    Namespace = "Core.Usage.Usage_Port",
    IsRunnable = true,
    Data = [[
-- 0 .. 10000

---@enum Core.PortUsage
local PortUsage = {
	-- DNS
	DNS_Heartbeat = 10,
	DNS = 53,

	HTTP = 80,

	-- FactoryControl
	FactoryControl_Heartbeat = 1250,
	FactoryControl = 1251,

	-- Callback
	CallbackService = 2400,
	CallbackService_Response = 2401,
}

return PortUsage
]]
}

return PackageData
