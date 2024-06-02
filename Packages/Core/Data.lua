local Data={
["Core.Config"] = [==========[
---@class Core.Config
local Config = {
    REFERENCE_REFRESH_DELAY = 60000
}

return Config

]==========],
["Core.Common.Cache"] = [==========[
---@alias Core.Cache.ValidKeyTypes string | integer

---@generic TKey : Core.Cache.ValidKeyTypes
---@class Core.Cache<TKey, TValue> : { m_cache: { [TKey]: TValue }, Add: (fun(self: Core.Cache<TKey, TValue>, key: TKey, value: TValue) : nil), Get: (fun(self: Core.Cache<TKey, TValue>, key: TKey) : TValue), TryGet: (fun(self: Core.Cache<TKey, TValue>, key: TKey, outValue: (Out<TValue>)) : boolean) }, object
---@field m_cache table<string|integer, any>
---@overload fun(): Core.Cache
local Cache = {}

---@private
function Cache:__init()
    self.m_cache = setmetatable({}, { __mode = "v" })
end

---@param indexOrId Core.Cache.ValidKeyTypes
---@param adapter any
function Cache:Add(indexOrId, adapter)
    self.m_cache[indexOrId] = adapter
end

---@param idOrIndex Core.Cache.ValidKeyTypes
---@return any
function Cache:Get(idOrIndex)
    local adapter = self.m_cache[idOrIndex]
    if not adapter then
        error("no adapter found with idOrIndex: " .. idOrIndex)
    end

    return adapter
end

---@param idOrIndex Core.Cache.ValidKeyTypes
---@param outAdapter Out<any>
---@return boolean
function Cache:TryGet(idOrIndex, outAdapter)
    local adapter = self.m_cache[idOrIndex]
    if not adapter then
        return false
    end

    outAdapter.Value = adapter
    return true
end

return class("Core.Cache", Cache)

]==========],
["Core.Common.Logger"] = [==========[
local Event = require("Core.Event.init")

---@alias Core.Logger.LogLevel
---|1 Trace
---|2 Debug
---|3 Info
---|4 Warning
---|5 Error
---|6 Fatal
---|10 Write (like normal log, but with the source of log call)

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
	padding = padding or "     "
	maxLevel = maxLevel or 5
	level = level or 1
	local lines = {}

	if type(node) == "table" and not Utils.Class.IsClass(node) then
		local keys = {}
		if type(properties) == "string" then
			local propSet = {}
			for p in string.gmatch(properties, "%b{}") do
				local propName = string.sub(p, 2, -2)
				for k in string.gmatch(propName, "[^,%s]+") do
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
			local line = ""
			if i == #keys then
				line = padding .. "└── " .. tostring(k)
			else
				line = padding .. "├── " .. tostring(k)
			end
			table.insert(lines, line)

			if level < maxLevel then
				---@cast properties string[]
				local childLines = tableToLineTree(node[k], maxLevel, properties, level + 1,
					padding .. (i == #keys and "    " or "│   "))
				for _, l in ipairs(childLines) do
					table.insert(lines, l)
				end
			elseif i == #keys then
				table.insert(lines, padding .. "└── ...")
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
	self.Name = (string.gsub(name, " ", "_") or "")
	self.OnLog = onLog or Event()
	self.OnClear = onClear or Event()
end

---@param name string
---@return Core.Logger
function Logger:subLogger(name)
	name = self.Name .. "." .. name
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
		message = ({ computer.magicTime() })[2] .. "-" .. computer.millis() .. " [" .. LogLevelToName[logLevel] .. "]: " .. self.Name
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

	if t == nil or type(t) ~= "table" then
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

	self.OnLog:Trigger(self, "")
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

return class("Core.Logger", Logger)

]==========],
["Core.Common.Task"] = [==========[
---@class Core.Task : object
---@field private m_func function
---@field private m_thread thread
---@field private m_closed boolean
---@field private m_success boolean
---@field private m_results any[]
---@field private m_error string?
---@field private m_traceback string?
---@overload fun(func: fun(...)) : Core.Task
local Task = {}

---@alias Core.Task.Constructor fun(func: fun(...))

---@private
---@param func fun(...)
function Task:__init(func)
	self.m_func = func

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

---@return "not created" | "normal" | "running" | "suspended" | "dead"
function Task:State()
	if self.m_thread == nil then
		return "not created"
	end
	return coroutine.status(self.m_thread)
end

---@param ... any parameters
---@return any ... results
function Task:Execute(...)
	---@param ... any
	local function invokeFunc(func, ...)
		return { func(...) }
	end

	self.m_thread = coroutine.create(invokeFunc)
	self.m_closed = false
	self.m_traceback = nil

	local success, results = coroutine.resume(self.m_thread, self.m_func, ...)
	self.m_success = success
	if success then
		self.m_results = results
	else
		self.m_error = results
	end

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
	if self.m_closed then
		return
	end
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

---@param logger Core.Logger?
---@param all boolean?
function Task:LogError(logger, all)
	self:Close()
	if not self.m_success and logger then
		logger:LogError("Task [Error]:\n" .. self:Traceback(all))
	end
end

return class("Core.Task", Task)

]==========],
["Core.Common.UUID"] = [==========[
local math = math
local string = string

---@class Core.UUID : object, Core.Json.ISerializable
---@field private m_head number[]
---@field private m_body number[]
---@field private m_tail number[]
---@overload fun(head: number[] | string, body: number[] | nil, tail: number[] | nil) : Core.UUID
local UUID = {}

---@private
---@type integer
UUID.Static__GeneratedCount = 0

---@private
---@type string
UUID.Static__TemplateRegex = "....%-....%-........"

---@param amount integer
---@return number[] char
local function generateRandomChars(amount)
    ---@type number[]
    local chars = {}

    for i = 1, amount, 1 do
        local j = math.random(0, 57)

        if j <= 7 then
            chars[i] = j + 48
        elseif j <= 32 then
            chars[i] = j + 65
        else
            chars[i] = j + 97
        end
    end
    return chars
end

---@return Core.UUID
function UUID.Static__New()
    math.randomseed(math.floor(computer.time()) + UUID.Static__GeneratedCount)
    local head = generateRandomChars(4)
    local body = generateRandomChars(4)
    local tail = generateRandomChars(8)
    return UUID(head, body, tail)
end

---@type Core.UUID
UUID.Static__Empty = {} --[[@as unknown]]

---@param str string
---@return integer[]
local function convertStringToCharArray(str)
    return { string.byte(str, 1, str:len()) }
end

---@return number[] head, number[] body, number[] tail
local function parse(str)
    local splittedStr = Utils.String.Split(str, "-")

    local head = convertStringToCharArray(splittedStr[1])
    local body = convertStringToCharArray(splittedStr[2])
    local tail = convertStringToCharArray(splittedStr[3])

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
---@param headOrString number[] | string
---@param body number[] | nil
---@param tail number[] | nil
function UUID:__init(headOrString, body, tail)
    if type(headOrString) == "string" then
        headOrString, body, tail = parse(headOrString)
    end
    ---@cast body number[]
    ---@cast tail number[]

    self:Raw__ModifyBehavior(function(modify)
        modify.CustomIndexing = false
    end)

    self.m_head = headOrString
    self.m_body = body
    self.m_tail = tail

    self:Raw__ModifyBehavior(function(modify)
        modify.CustomIndexing = true
    end)
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

class("Core.UUID", UUID, { Inherit = require("Core.Json.ISerializable") })

local empty = {}
local splittedTemplate = Utils.String.Split(UUID.Static__TemplateRegex, "%-")
for index, splittedTemplatePart in pairs(splittedTemplate) do
    empty[index] = {}
    for _ in string.gmatch(splittedTemplatePart, ".") do
        table.insert(empty[index], 48)
    end
end

UUID.Static__Empty = UUID(table.unpack(empty))

return UUID

]==========],
["Core.Common.Watchable"] = [==========[
local Event = require("Core.Event.init")

---@alias Core.Watchable.OnSetup fun(Watchable: Core.Watchable)
---@alias Core.Watchable.OnClose fun(Watchable: Core.Watchable)

---@class Core.Watchable : object
---@field private m_Event Core.Event
---@field private m_IsSetup boolean
---@field private m_OnSetup Core.Watchable.OnSetup?
---@field private m_OnClose Core.Watchable.OnClose?
---@overload fun(onSetup: Core.Watchable.OnSetup?, onClose: Core.Watchable.OnClose?) : Core.Watchable
local Watchable = {}

---@alias Core.Watchable.Constructor fun(onSetup: Core.Watchable.OnSetup?, onClose: Core.Watchable.OnClose?)

---@private
---@param onSetup Core.Watchable.OnSetup?
---@param onClose Core.Watchable.OnClose?
function Watchable:__init(onSetup, onClose)
    self.m_Event = Event()

    self.m_IsSetup = false
    self.m_OnSetup = onSetup
    self.m_OnClose = onClose
end

---@return integer count
function Watchable:Count()
    return self.m_Event:Count()
end

---@private
---@param onlyClose boolean?
function Watchable:Check(onlyClose)
    local count = self:Count()

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
---@return integer index
function Watchable:AddTask(task)
    local index = self.m_Event:AddTask(task)
    self:Check()
    return index
end

---@param index integer
function Watchable:RemoveTask(index)
    self.m_Event:Remove(index)
    self:Check()
end

---@param task Core.Task
---@return integer index
function Watchable:AddTaskOnce(task)
    local index = self.m_Event:AddTaskOnce(task)
    self:Check()
    return index
end

---@param index integer
function Watchable:RemoveTaskOnce(index)
    self.m_Event:RemoveOnce(index)
    self:Check()
end

---@param logger Core.Logger?
---@param ... any
function Watchable:Trigger(logger, ...)
    self.m_Event:Trigger(logger, ...)
    self:Check(true)
end

return class("Core.Watchable", Watchable)

]==========],
["Core.Event.EventPullAdapter"] = [==========[
local Event = require("Core.Event.init")

--- Handles events from `event.pull()`.
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

	local allEvent = self.m_events["*"]
	if allEvent then
		allEvent:Trigger(self.m_logger, eventPullData)
		if allEvent:Count() == 0 then
			self.m_events["*"] = nil
		end
	end

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

---@param signalName string | "*"
---@return Core.Event
function EventPullAdapter:GetEvent(signalName)
	local event = self.m_events[signalName]
	if event then
		return event
	end

	event = Event()
	self.m_events[signalName] = event
	return event
end

---@param signalName string | "*"
---@param task Core.Task
---@return integer index
function EventPullAdapter:AddTask(signalName, task)
	local event = self:GetEvent(signalName)
	return event:AddTask(task)
end

---@param signalName string | "*"
---@param task Core.Task
---@return integer index
function EventPullAdapter:AddTaskOnce(signalName, task)
	local event = self:GetEvent(signalName)
	return event:AddTaskOnce(task)
end

---@param signalName string | "*"
---@param index integer
function EventPullAdapter:Remove(signalName, index)
	local event = self.m_events[signalName]
	if not event then
		return
	end

	event:Remove(index)
end

--- Waits for an event to be handled or timeout
--- Returns true if event was handled and false if it timeout
---
---@async
---@param timeoutSeconds number?
---@return boolean gotEvent
function EventPullAdapter:Wait(timeoutSeconds)
	self.m_logger:LogTrace("## waiting for event pull ##")
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

	self.m_logger:LogDebug("event with signalName: "
		.. eventPullData[1] .. " was received from component: "
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
	self.m_logger:LogDebug("## started event pull loop ##")
	while true do
		self:Wait()
	end
end

return EventPullAdapter

]==========],
["Core.Event.init"] = [==========[
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

return class("Core.Event", Event)

]==========],
["Core.FileSystem.File"] = [==========[
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

---@param mode FIN.Filesystem.File.SeekMode
---@param offset integer
function File:Seek(mode, offset)
    self:CheckState()

    self.m_file:seek(mode, offset)
end

function File:Close()
    self.m_file:close()
    self.m_file = nil
end

function File:Clear()
    local wasOpen = self:IsOpen()
    if wasOpen then
        self:Close()
    end

    if not filesystem.exists(self.m_path:GetPath()) then
        return
    end

    filesystem.remove(self.m_path:GetPath())

    local file = filesystem.open(self.m_path:GetPath(), "w")
    file:write("")
    file:close()

    if wasOpen then
        self.m_file = filesystem.open(self.m_path:GetPath(), self.m_mode)
    end
end

return class("Core.FileSystem.File", File)

]==========],
["Core.FileSystem.Path"] = [==========[
---@param str string
---@return string str
local function formatStr(str)
    str = str:gsub("\\", "/")
    return str
end

---@class Core.FileSystem.Path : object
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

    local length = #pathOrNodes
    local node = pathOrNodes[length]
    if node ~= "" and not node:find("^.+%..+$") then
        pathOrNodes[length + 1] = ""
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

function Path:Exists()
    local path = self:GetPath()
    return filesystem.exists(path)
end

---@return string
function Path:GetParentFolder()
    local copy = Utils.Table.Copy(self.m_nodes)
    local length = #copy

    if length > 0 then
        if length > 1 and copy[length] == "" then
            copy[length] = nil
            copy[length - 1] = ""
        else
            copy[length] = nil
        end
    end

    return Utils.String.Join(copy, "/")
end

---@return Core.FileSystem.Path
function Path:GetParentFolderPath()
    local copy = self:Copy()
    local length = #copy.m_nodes

    if length > 0 then
        if length > 1 and copy.m_nodes[length] == "" then
            copy.m_nodes[length] = nil
            copy.m_nodes[length - 1] = ""
        else
            copy.m_nodes[length] = nil
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

return class("Core.FileSystem.Path", Path)

]==========],
["Core.Json.ISerializable"] = [==========[
---@alias Core.Json.Serializable.Types
---| string
---| number
---| boolean
---| table
---| Core.Json.ISerializable

---@class Core.Json.ISerializable
local ISerializable = {}
---@return any ...
function ISerializable:Serialize()
end

ISerializable.Serialize = Utils.Class.IsInterface

---@param ... any
---@return any obj
function ISerializable:Static__Deserialize(...)
    return self(...)
end

return interface("Core.Json.ISerializable", ISerializable)

]==========],
["Core.Json.Json"] = [==========[
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

]==========],
["Core.Json.JsonSerializer"] = [==========[
local Json = require("Core.Json.Json")
local ISerializable = require("Core.Json.ISerializable")
local NAME_ISERIALIZABLE = nameof(ISerializable)

---@class Core.Json.Serializer : object
---@field private m_typeInfos table<string, Freemaker.ClassSystem.Type>
---@overload fun(typeInfos: Freemaker.ClassSystem.Type[]?) : Core.Json.Serializer
local JsonSerializer = {}

---@type Core.Json.Serializer
JsonSerializer.Static__Serializer = {} --[[@as unknown]]

---@private
---@param typeInfos Freemaker.ClassSystem.Type[]?
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

---@private
---@param typeInfo Freemaker.ClassSystem.Type
---@return Core.Json.Serializer
function JsonSerializer:AddTypeInfo(typeInfo)
    if Utils.Table.ContainsKey(self.m_typeInfos, typeInfo.Name) then
        error("serializer already contains type: " .. typeInfo.Name)
    end
    
    self.m_typeInfos[typeInfo.Name] = typeInfo

    return self
end

---@param class object
---@return Core.Json.Serializer
function JsonSerializer:AddClass(class)
    local typeInfo = typeof(class)
    if not typeInfo then
        error("unable to get type of passed class")
    end

    if typeInfo.Options.IsAbstract or typeInfo.Options.IsInterface then
        error("passed class needs cannot be abstract or an interface")
    end

    if not Utils.Class.HasInterface(class, NAME_ISERIALIZABLE) then
        error("class: " .. typeInfo.Name .. " has not " .. NAME_ISERIALIZABLE .. " as interface", 2)
    end

    return self:AddTypeInfo(typeInfo)
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
---@param class Core.Json.ISerializable
---@return table data
function JsonSerializer:serializeClass(class)
    local typeInfo = typeof(class)
    if not typeInfo then
        error("unable to get type from class")
    end

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

    if Utils.Class.HasInterface(obj, NAME_ISERIALIZABLE) then
        ---@cast obj Core.Json.ISerializable
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

    local classBlueprint = typeInfo.Blueprint --[[@as Core.Json.ISerializable]]

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

    if not classBlueprint.Static__Deserialize then
        return ISerializable.Static__Deserialize(classBlueprint, table.unpack(data))
    end

    return classBlueprint:Static__Deserialize(table.unpack(data))
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

class("Core.Json.Serializer", JsonSerializer)

JsonSerializer.Static__Serializer = JsonSerializer()
JsonSerializer.Static__Serializer:AddClass(require("Core.Common.UUID"))

return JsonSerializer

]==========],
["Core.References.IReference"] = [==========[
local Config = require("Core.Config")

---@generic TReference : Engine.Object
---@class Core.IReference<TReference> : { Get: fun() : TReference }
---@field protected m_obj Engine.Object?
---@field m_expires number
local IReference = {}

IReference.m_expires = 0

---@return any
function IReference:Get()
    if self.m_expires < computer.millis() then
        if not self:Fetch() then
            return nil
        end

        self.m_expires = computer.millis() + Config.REFERENCE_REFRESH_DELAY
    end

    return self.m_obj
end

---@return boolean found
function IReference:Fetch()
    return false
end

IReference.Fetch = Utils.Class.IsInterface

---@return boolean isValid
function IReference:Check()
    return self:Get() == nil
end

return interface("Core.IReference", IReference)

]==========],
["Core.References.PCIDeviceReference"] = [==========[
---@class Core.PCIDeviceReference<T> : object, Core.IReference<T>
---@field m_class FIN.PCIDevice
---@field m_index integer
---@overload fun(class: FIN.Class, index: integer) : Core.PCIDeviceReference
local PCIDeviceReference = {}

---@private
---@param class FIN.PCIDevice
---@param index integer
function PCIDeviceReference:__init(class, index)
    self.m_class = class
    self.m_index = index
end

---@return boolean found
function PCIDeviceReference:Fetch()
    local obj = computer.getPCIDevices(self.m_class)[self.m_index]
    self.m_obj = obj
    return obj ~= nil
end

return class("Core.PCIDeviceReference", PCIDeviceReference,
    { Inherit = require("Core.References.IReference") })

]==========],
["Core.References.ProxyReference"] = [==========[
---@class Core.ProxyReference<T> : object, Core.IReference<T>
---@field m_id FIN.UUID
---@overload fun(id: FIN.UUID) : Core.ProxyReference
local ProxyReference = {}

---@private
---@param id FIN.UUID
function ProxyReference:__init(id)
    self.m_id = id
end

function ProxyReference:Fetch()
    local obj = component.proxy(self.m_id)
    self.m_obj = obj
    return obj ~= nil
end

return class("Core.ProxyReference", ProxyReference,
    { Inherit = require("Core.References.IReference") })

]==========],
["Core.Usage.init"] = [==========[
return {
    Ports = require("Core.Usage.Usage_Port"),
    Events = require("Core.Usage.Usage_EventName")
}

]==========],
["Core.Usage.Usage_EventName"] = [==========[
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

]==========],
["Core.Usage.Usage_Port"] = [==========[
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

]==========],
}

return Data
