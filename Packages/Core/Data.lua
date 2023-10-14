---@meta
local PackageData = {}

PackageData["CoreLogger"] = {
    Location = "Core.Logger",
    Namespace = "Core.Logger",
    IsRunnable = true,
    Data = [[
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
---@field private logLevel Core.Logger.LogLevel
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
	self.logLevel = logLevel
	self.Name = (string.gsub(name, ' ', '_') or '')
	self.OnLog = onLog or Event()
	self.OnClear = onClear or Event()
end

---@param name string
---@return Core.Logger
function Logger:subLogger(name)
	name = self.Name .. '.' .. name
	local logger = Logger(name, self.logLevel)
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
	if logLevel < self.logLevel then
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
	if logLevel < self.logLevel then
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
	if logLevel < self.logLevel then
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
]]
}

PackageData["CorePath"] = {
    Location = "Core.Path",
    Namespace = "Core.Path",
    IsRunnable = true,
    Data = [[
---@param str string
---@return string str
local function formatStr(str)
    str = str:gsub("\\", "/")
    return str
end

---@class Core.Path
---@field private nodes string[]
---@overload fun(pathOrNodes: (string | string[])?) : Core.Path
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
        self.nodes = {}
        return
    end

    if type(pathOrNodes) == "string" then
        pathOrNodes = formatStr(pathOrNodes)
        self.nodes = Utils.String.Split(pathOrNodes, "/")
        return
    end

    self.nodes = pathOrNodes
end

---@return string path
function Path:GetPath()
    return Utils.String.Join(self.nodes, "/")
end

---@private
Path.__tostring = Path.GetPath

---@return boolean
function Path:IsEmpty()
    return #self.nodes == 0 or (#self.nodes == 2 and self.nodes[1] == "" and self.nodes[2] == "")
end

---@return boolean
function Path:IsFile()
    return self.nodes[#self.nodes] ~= ""
end

---@return boolean
function Path:IsDir()
    return self.nodes[#self.nodes] == ""
end

---@return string
function Path:GetParentFolder()
    local copy = Utils.Table.Copy(self.nodes)
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

---@return Core.Path
function Path:GetParentFolderPath()
    local copy = self:Copy()
    local lenght = #copy.nodes

    if lenght > 0 then
        if lenght > 1 and copy.nodes[lenght] == "" then
            copy.nodes[lenght] = nil
            copy.nodes[lenght - 1] = ""
        else
            copy.nodes[lenght] = nil
        end
    end

    return copy
end

---@return string fileName
function Path:GetFileName()
    if not self:IsFile() then
        error("path is not a file: " .. self:GetPath())
    end

    return self.nodes[#self.nodes]
end

---@return string fileExtension
function Path:GetFileExtension()
    if not self:IsFile() then
        error("path is not a file: " .. self:GetPath())
    end

    local fileName = self.nodes[#self.nodes]

    local _, _, extension = fileName:find("^.+(%..+)$")
    return extension
end

---@return string fileStem
function Path:GetFileStem()
    if not self:IsFile() then
        error("path is not a file: " .. self:GetPath())
    end

    local fileName = self.nodes[#self.nodes]

    local _, _, stem = fileName:find("^(.+)%..+$")
    return stem
end

---@return Core.Path
function Path:Normalize()
    ---@type string[]
    local newNodes = {}

    for index, value in ipairs(self.nodes) do
        if value == "." then
        elseif value == "" then
            if index == 1 or index == #self.nodes then
                newNodes[index] = ""
            end
        elseif value == ".." then
            if index ~= 1 then
                newNodes[#newNodes] = nil
            end
        else
            newNodes[#newNodes + 1] = value
        end
    end

    if not newNodes[#newNodes]:find("^.+%..+$") then
        newNodes[#newNodes + 1] = ""
    end

    self.nodes = newNodes
    return self
end

---@param path string
---@return Core.Path
function Path:Append(path)
    path = formatStr(path)
    local newNodes = Utils.String.Split(path, "/")

    for _, value in ipairs(newNodes) do
        self.nodes[#self.nodes + 1] = value
    end

    self:Normalize()

    return self
end

---@param path string
---@return Core.Path
function Path:Extend(path)
    local copy = self:Copy()
    return copy:Append(path)
end

---@return Core.Path
function Path:Copy()
    local copyNodes = Utils.Table.Copy(self.nodes)
    return Path(copyNodes)
end

return Utils.Class.CreateClass(Path, "Core.Path")
]]
}

PackageData["CorePortUsage"] = {
    Location = "Core.PortUsage",
    Namespace = "Core.PortUsage",
    IsRunnable = true,
    Data = [[
-- 0 .. 2^1023

---@enum Core.PortUsage
local PortUsage = {
	Heartbeats = 10,
	DNS = 53,
	HTTP = 80
}

return PortUsage
]]
}

PackageData["CoreTask"] = {
    Location = "Core.Task",
    Namespace = "Core.Task",
    IsRunnable = true,
    Data = [[
---@class Core.Task : object
---@field package func function
---@field package passthrough any
---@field package thread thread
---@field package closed boolean
---@field private success boolean
---@field private results any[]
---@field private traceback string?
---@overload fun(func: function, passthrough: any) : Core.Task
local Task = {}

---@private
---@param func function
---@param passthrough any
function Task:__init(func, passthrough)
    self.func = func
    self.passthrough = passthrough
    self.closed = false
    self.success = true
    self.results = {}
end

---@return boolean
function Task:IsSuccess()
    return self.success
end

---@return any ... results
function Task:GetResults()
    return table.unpack(self.results)
end

---@return any[] results
function Task:GetResultsArray()
    return self.results
end

---@return string
function Task:GetTraceback()
    return self:Traceback()
end

---@private
---@param ... any args
function Task:invokeThread(...)
    self.success, self.results = coroutine.resume(self.thread, ...)
end

---@param ... any parameters
---@return any ... results
function Task:Execute(...)
    ---@param ... any parameters
    ---@return any[] returns
    local function invokeFunc(...)
        ---@type any[]
        local result
        if self.passthrough ~= nil then
            result = { self.func(self.passthrough, ...) }
        else
            result = { self.func(...) }
        end
        if coroutine.isyieldable(self.thread) then
            --? Should always return here
            return coroutine.yield(result)
        end
        --! Should never return here
        return result
    end

    self.thread = coroutine.create(invokeFunc)
    self.closed = false
    self.traceback = nil

    self:invokeThread(...)
    return table.unpack(self.results)
end

---@private
function Task:CheckThreadState()
    if self.thread == nil then
        error("cannot resume a not started task")
    end
    if self.closed then
        error("cannot resume a closed task")
    end
    if coroutine.status(self.thread) == "running" then
        error("cannot resume running task")
    end
    if coroutine.status(self.thread) == "dead" then
        error("cannot resume dead task")
    end
end

---@param ... any parameters
---@return any ... results
function Task:Resume(...)
    self:CheckThreadState()
    self:invokeThread(...)
    return table.unpack(self.results)
end

function Task:Close()
    if self.closed then return end
    self:Traceback()
    coroutine.close(self.thread)
    self.closed = true
end

---@private
---@return string traceback
function Task:Traceback()
    if self.traceback ~= nil then
        return self.traceback
    end
    local error = ""
    if type(self.results) == "string" then
        error = self.results --{{{@as string}}}
    end
    self.traceback = debug.traceback(self.thread, error)
    return self.traceback
end

---@return "not created" | "dead" | "normal" | "running" | "suspended"
function Task:State()
    if self.thread == nil then
        return "not created"
    end
    return coroutine.status(self.thread);
end

---@param logger Core.Logger?
function Task:LogError(logger)
    self:Close()
    if not self.success and logger then
        logger:LogError("Task: \n" .. self:Traceback() .. debug.traceback():sub(17))
    end
end

return Utils.Class.CreateClass(Task, "Core.Task")
]]
}

PackageData["CoreUUID"] = {
    Location = "Core.UUID",
    Namespace = "Core.UUID",
    IsRunnable = true,
    Data = [[
local math = math
local string = string
local random = math.random

---@class Core.UUID : Core.Json.Serializable
---@field private head number[]
---@field private body number[]
---@field private tail number[]
---@overload fun(head: number[], body: number[], tail: number[]) : Core.UUID
local UUID = {}

--- Replaces 'x' in template with random character.
---@param amount integer
---@return number[] char
local function generateRandomChars(amount)
    ---@type number[]
    local chars = {}
    for i = 1, amount, 1 do
        local j = random(1, 3)

        if j == 1 then
            chars[i] = random(48, 57)
        elseif j == 2 then
            chars[i] = random(65, 90)
        elseif j == 3 then
            chars[i] = random(97, 122)
        end
    end
    return chars
end

---@return Core.UUID
function UUID.Static__New()
    math.randomseed(os.time())
    local head = generateRandomChars(6)
    local body = generateRandomChars(4)
    local tail = generateRandomChars(6)
    return UUID(head, body, tail)
end

local emptyUUID = nil
---@return Core.UUID
function UUID.Static__Empty()
    if emptyUUID then
        return emptyUUID
    end

    emptyUUID = UUID({ 48, 48, 48, 48, 48, 48 }, { 48, 48, 48, 48 }, { 48, 48, 48, 48, 48, 48 })

    return UUID.Static__Empty()
end

---@param str string
---@return integer[]
local function convertStringToCharArray(str)
    return { string.byte(str, 1, str:len()) }
end

---@param str string
---@return Core.UUID?
function UUID.Static__Parse(str)
    local splitedStr = Utils.String.Split(str, "-")
    if not splitedStr[1] or splitedStr[1]:len() ~= 6
        or not splitedStr[2] or splitedStr[2]:len() ~= 4
        or not splitedStr[3] or splitedStr[3]:len() ~= 6
    then
        return nil
    end

    local head = convertStringToCharArray(splitedStr[1])
    local body = convertStringToCharArray(splitedStr[2])
    local tail = convertStringToCharArray(splitedStr[3])

    return UUID(head, body, tail)
end

---@private
---@param head number[]
---@param body number[]
---@param tail number[]
function UUID:__init(head, body, tail)
    self.head = head
    self.body = body
    self.tail = tail
end

---@private
function UUID:__newindex()
    error("Core.UUID is completely read only", 3)
end

---@private
---@param other Core.UUID
---@return boolean isSame
function UUID:__eq(other)
    if type(other) ~= "table" or not other.Static__GetType or other:Static__GetType() ~= "Core.UUID" then
        local typeString = type(other)
        if type(other) == "table" and other.Static__GetType then
            typeString = other:Static__GetType().Name
        end
        error("wrong argument #2: (Core.UUID expected; got " .. typeString .. ")")
        return false
    end

    for i, char in ipairs(self.head) do
        if char ~= other.head[i] then
            return false
        end
    end

    for i, char in ipairs(self.body) do
        if char ~= other.body[i] then
            return false
        end
    end

    for i, char in ipairs(self.tail) do
        if char ~= other.tail[i] then
            return false
        end
    end

    return true
end

---@private
function UUID:__tostring()
    local str = ""

    for _, char in ipairs(self.head) do
        str = str .. string.char(char)
    end

    str = str .. "-"

    for _, char in ipairs(self.body) do
        str = str .. string.char(char)
    end

    str = str .. "-"

    for _, char in ipairs(self.tail) do
        str = str .. string.char(char)
    end

    return str
end

--#region - Serializable -

function UUID:Static__Serialize()
    return tostring(self)
end

function UUID.Static__Deserialize(data)
    return UUID.Static__Parse(data)
end

--#endregion

return Utils.Class.CreateClass(UUID, 'Core.UUID', require("Core.Json.Serializable"))
]]
}

PackageData["CoreEventEvent"] = {
    Location = "Core.Event.Event",
    Namespace = "Core.Event.Event",
    IsRunnable = true,
    Data = [[
---@class Core.Event : object
---@field private funcs Core.Task[]
---@field private onceFuncs Core.Task[]
---@operator len() : integer
---@overload fun() : Core.Event
local Event = {}

---@private
function Event:__init()
    self.funcs = {}
    self.onceFuncs = {}
end

---@param task Core.Task
---@return Core.Event
function Event:AddListener(task)
    table.insert(self.funcs, task)
    return self
end

Event.On = Event.AddListener

---@param task Core.Task
---@return Core.Event
function Event:AddListenerOnce(task)
    table.insert(self.onceFuncs, task)
    return self
end

Event.Once = Event.AddListenerOnce

---@param logger Core.Logger?
---@param ... any
function Event:Trigger(logger, ...)
    for _, task in ipairs(self.funcs) do
        task:Execute(...)
    end

    for _, task in ipairs(self.onceFuncs) do
        task:Execute(...)
    end
    self.OnceFuncs = {}
end

---@alias Core.Event.Mode
---|"Permanent"
---|"Once"

---@return Dictionary<Core.Event.Mode, Core.Task[]>
function Event:Listeners()
    ---@type Core.Task[]
    local permanentTask = {}
    for _, task in ipairs(self.funcs) do
        table.insert(permanentTask, task)
    end

    ---@type Core.Task[]
    local onceTask = {}
    for _, task in ipairs(self.onceFuncs) do
        table.insert(onceTask, task)
    end
    return {
        Permanent = permanentTask,
        Once = onceTask
    }
end

---@return integer count
function Event:GetCount()
    return #self.funcs + #self.onceFuncs
end

---@param event Core.Event
---@return Core.Event event
function Event:CopyTo(event)
    for _, listener in ipairs(self.funcs) do
        event:AddListener(listener)
    end
    for _, listener in ipairs(self.onceFuncs) do
        event:AddListenerOnce(listener)
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
]]
}

PackageData["CoreFileSystemFile"] = {
    Location = "Core.FileSystem.File",
    Namespace = "Core.FileSystem.File",
    IsRunnable = true,
    Data = [[
local Path = require("Core.Path")

---@alias Core.FileSystem.File.OpenModes
---|"r" read only -> file stream can just read from file. If file doesn’t exist, will return nil
---|"w" write -> file stream can read and write creates the file if it doesn’t exist
---|"a" end of file -> file stream can read and write cursor is set to the end of file
---|"+r" truncate -> file stream can read and write all previous data in file gets dropped
---|"+a" append -> file stream can read the full file but can only write to the end of the existing file

---@class Core.FileSystem.File : object
---@field private path Core.Path
---@field private mode Core.FileSystem.File.OpenModes?
---@field private file FIN.Filesystem.File?
---@overload fun(path: string | Core.Path) : Core.FileSystem.File
local File = {}

---@param path Core.Path | string
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

---@param path Core.Path | string
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
---@param path string | Core.Path
function File:__init(path)
    if type(path) == "string" then
        self.path = Path(path)
        return
    end

    self.path = path
end

---@return string
function File:GetPath()
    return self.path:GetPath()
end

---@return boolean exists
function File:Exists()
    return filesystem.exists(self.path:GetPath())
end

---@return boolean isOpen
---@nodiscard
function File:IsOpen()
    if not self.file then
        return false
    end

    return true
end

---@private
function File:CheckState()
    if not self:IsOpen() then
        error("file is not open: " .. self.path:GetPath(), 3)
    end
end

---@param mode Core.FileSystem.File.OpenModes
---@return boolean isOpen
---@nodiscard
function File:Open(mode)
    local file

    if not filesystem.exists(self.path:GetPath()) then
        local parentFolder = self.path:GetParentFolder()
        if not filesystem.exists(parentFolder) then
            error("parent folder does not exist: " .. parentFolder)
        end

        if mode == "r" then
            file = filesystem.open(self.path:GetPath(), "w")
            file:write("")
            file:close()
            file = nil
        end

        return false
    end

    self.file = filesystem.open(self.path:GetPath(), mode)
    self.mode = mode

    return true
end

---@param data string
function File:Write(data)
    self:CheckState()

    self.file:write(data)
end

---@param length integer
function File:Read(length)
    self:CheckState()

    return self.file:read(length)
end

---@param offset integer
function File:Seek(offset)
    self:CheckState()

    self.file:seek(offset)
end

function File:Close()
    self.file:close()
    self.file = nil
end

function File:Clear()
    local isOpen = self:IsOpen()
    if isOpen then
        self:Close()
    end

    if not filesystem.exists(self.path:GetPath()) then
        return
    end

    filesystem.remove(self.path:GetPath())

    local file = filesystem.open(self.path:GetPath(), "w")
    file:write("")
    file:close()

    if isOpen then
        self.file = filesystem.open(self.path:GetPath(), self.mode)
    end
end

return Utils.Class.CreateClass(File, "Core.FileSystem.File")
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
---|table
---|string
---|number
---|boolean

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
---@field private _TypeInfos Utils.Class.Type[]
---@overload fun(typeInfos: Utils.Class.Type[]?) : Core.Json.Serializer
local Serializer = {}

---@param typeInfos Utils.Class.Type[]?
function Serializer:__init(typeInfos)
    self._TypeInfos = typeInfos or {}
end

---@param typeInfo Utils.Class.Type
---@return Core.Json.Serializer
function Serializer:AddTypeInfo(typeInfo)
    table.insert(self._TypeInfos, typeInfo)
    return self
end

---@param typeInfos Utils.Class.Type[]
---@return Core.Json.Serializer
function Serializer:AddTypeInfos(typeInfos)
    for _, typeInfo in ipairs(typeInfos) do
        table.insert(self._TypeInfos, typeInfo)
    end
    return self
end

---@private
---@param class object
---@return table data
function Serializer:serializeClass(class)
    local typeInfo = class:Static__GetType()
    if not Utils.Class.HasBaseClass("Core.Json.Serializable", typeInfo) then
        error("can not serialize class: " .. typeInfo.Name .. " use 'Core.Json.Serializable' as base class")
    end
    ---@cast class Core.Json.Serializable

    local data = { __Type = typeInfo.Name, __Data = class:Static__Serialize() }

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
function Serializer:serializeInternal(obj)
    local objType = type(obj)
    if objType ~= "table" then
        if not Utils.Table.ContainsKey(Json.type_func_map, objType) then
            error("can not serialize: " .. objType .. " value: " .. tostring(obj))
            return {}
        end

        return obj
    end

    if Utils.Class.IsClass(obj) then
        ---@cast obj object
        return self:serializeClass(obj)
    end

    for key, value in next, obj, nil do
        local valueType = type(value)
        if Utils.Class.IsClass(value) then
            ---@cast value object
            obj[key] = self:serializeClass(value)
        elseif not Utils.Table.ContainsKey(Json.type_func_map, valueType) then
            error("can not serialize: " .. valueType .. " value: " .. tostring(value))
            return {}
        end
    end
    return obj
end

---@param obj table
---@return string str
function Serializer:Serialize(obj)
    return Json.encode(self:serializeInternal(obj))
end

---@private
---@param t table
---@return boolean isDeserializedClass
local function isDeserializedClass(t)
    if not t.__Type then
        return false
    end

    return true
end

---@private
---@param t table
---@return object class
function Serializer:deserializeClass(t)
    local data = t.__Data
    ---@type Core.Json.Serializable
    local classTemplate

    for _, typeInfo in ipairs(self._TypeInfos) do
        if typeInfo.Name == t.__Type then
            classTemplate = Utils.Class.CreateClassTemplate(typeInfo) --{{{@as Core.Json.Serializable}}}
            break
        end
    end

    if type(data) == "table" then
        for key, value in next, data, nil do
            if type(value) == "table" and isDeserializedClass(value) then
                data[key] = self:deserializeClass(value)
            end
        end
    end


    return classTemplate.Static__Deserialize(data)
end

---@private
---@param t table
---@return any obj
function Serializer:deserializeInternal(t)
    if isDeserializedClass(t) then
        return self:deserializeClass(t)
    end

    for key, value in next, t, nil do
        if isDeserializedClass(value) then
            t[key] = self:deserializeClass(value)
        end
    end

    return t
end

---@param str string
---@return any obj
function Serializer:Deserialize(str)
    local obj = Json.decode(str)

    if type(obj) == "table" then
        return self:deserializeInternal(obj)
    end

    return obj
end

return Utils.Class.CreateClass(Serializer, "Core.Json.JsonSerializer")
]]
}

PackageData["CoreJsonSerializable"] = {
    Location = "Core.Json.Serializable",
    Namespace = "Core.Json.Serializable",
    IsRunnable = true,
    Data = [[
---@class Core.Json.Serializable : object
local Serializable = {}

---@return table data
function Serializable:Static__Serialize()
    error("function not overriden")
end

---@param data table
---@return table obj
function Serializable.Static__Deserialize(data)
    error("function not overriden")
end

return Utils.Class.CreateClass(Serializable, "Core.Json.Serializable")
]]
}

return PackageData
