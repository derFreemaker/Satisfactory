---@meta
local PackageData = {}

PackageData["CoreLogger"] = {
    Location = "Core.Logger",
    Namespace = "Core.Logger",
    IsRunnable = true,
    Data = [[
local Event = require('Core.Event.Event')

---@alias Core.Logger.LogLevel
---|1 Trace
---|2 Debug
---|3 Info
---|4 Warning
---|5 Error
---|10 Write (will only write content no information like normal a log)

---@enum Core.Logger.LogLevel.ToName
local LogLevelToName = {
	[1] = "Trace",
	[2] = "Debug",
	[3] = "Info",
	[4] = "Warning",
	[5] = "Error",
	[10] = "Write"
}

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

---@param obj any
---@return string messagePart
local function formatMessagePart(obj)
	if obj == nil then
		return "nil"
	end

	if type(obj) == "table" then
		local str = ""
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
	if logLevel < self._LogLevel then
		return
	end

	local message = formatMessage(...)
	if not message then
		return
	end

	if logLevel ~= 10 then
		message = ({ computer.magicTime() })[2] .. " [" .. LogLevelToName[logLevel] .. "]: " .. self.Name .. "\n"
			.. "    " .. message:gsub("\n", "\n    ")
	end
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
	if logLevel < self._LogLevel then
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

function Logger:LogWrite(...)
	self:Log(10, ...)
end

return Utils.Class.CreateClass(Logger, 'Core.Logger')
]]
}

PackageData["CoreTask"] = {
    Location = "Core.Task",
    Namespace = "Core.Task",
    IsRunnable = true,
    Data = [[
---@class Core.Task : object
---@field private _Func function
---@field private _Passthrough any
---@field private _Thread thread
---@field private _Closed boolean
---@field private _Success boolean
---@field private _Results any[]
---@field private _Traceback string?
---@overload fun(func: function, passthrough: any) : Core.Task
local Task = {}

---@private
---@param func function
---@param passthrough any
function Task:__init(func, passthrough)
    self._Func = func
    self._Passthrough = passthrough
    self._Closed = false
    self._Success = true
    self._Results = {}
end

---@return boolean
function Task:IsSuccess()
    return self._Success
end

---@return any ... results
function Task:GetResults()
    return table.unpack(self._Results)
end

---@return any[] results
function Task:GetResultsArray()
    return self._Results
end

---@return string
function Task:GetTraceback()
    return self:Traceback()
end

---@private
---@param ... any args
function Task:invokeThread(...)
    self._Success, self._Results = coroutine.resume(self._Thread, ...)
end

---@param ... any parameters
---@return any ... results
function Task:Execute(...)
    ---@param ... any parameters
    ---@return any[] returns
    local function invokeFunc(...)
        ---@type any[]
        local result
        if self._Passthrough ~= nil then
            result = { self._Func(self._Passthrough, ...) }
        else
            result = { self._Func(...) }
        end
        if coroutine.isyieldable(self._Thread) then
            --? Should always return here
            return coroutine.yield(result)
        end
        --! Should never return here
        return result
    end

    self._Thread = coroutine.create(invokeFunc)
    self._Closed = false
    self._Traceback = nil

    self:invokeThread(...)
    return table.unpack(self._Results)
end

---@private
function Task:CheckThreadState()
    if self._Thread == nil then
        error("cannot resume a not started task")
    end
    if self._Closed then
        error("cannot resume a closed task")
    end
    if coroutine.status(self._Thread) == "running" then
        error("cannot resume running task")
    end
    if coroutine.status(self._Thread) == "dead" then
        error("cannot resume dead task")
    end
end

---@param ... any parameters
---@return any ... results
function Task:Resume(...)
    self:CheckThreadState()
    self:invokeThread(...)
    return table.unpack(self._Results)
end

function Task:Close()
    if self._Closed then return end
    self:Traceback()
    coroutine.close(self._Thread)
    self._Closed = true
end

---@private
---@return string traceback
function Task:Traceback()
    if self._Traceback ~= nil then
        return self._Traceback
    end
    local error = ""
    if type(self._Results) == "string" then
        error = self._Results --{{{@as string}}}
    end
    self._Traceback = debug.traceback(self._Thread, error)
    return self._Traceback
end

---@return "not created" | "dead" | "normal" | "running" | "suspended"
function Task:State()
    if self._Thread == nil then
        return "not created"
    end
    return coroutine.status(self._Thread);
end

---@param logger Core.Logger?
function Task:LogError(logger)
    self:Close()
    if not self._Success and logger then
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
---@field private _Head number[]
---@field private _Body number[]
---@field private _Tail number[]
---@overload fun(head: number[], body: number[], tail: number[]) : Core.UUID
local UUID = {}

---@type integer
UUID.Static__GeneratedCount = 0

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
    math.randomseed(computer.millis() + computer.time() + UUID.Static__GeneratedCount)
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
    if not splitedStr[1] or splitedStr[1]:len() ~= 6
        or not splitedStr[2] or splitedStr[2]:len() ~= 4
        or not splitedStr[3] or splitedStr[3]:len() ~= 6
    then
        error("Unable to parse: " .. tostring(str))
        return getEmptyData()
    end

    local head = convertStringToCharArray(splitedStr[1])
    local body = convertStringToCharArray(splitedStr[2])
    local tail = convertStringToCharArray(splitedStr[3])

    return head, body, tail
end

---@param str string
---@return Core.UUID?
function UUID.Static__Parse(str)
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

    self._Head = headOrSring
    self._Body = body
    self._Tail = tail
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

    for i, char in ipairs(self._Head) do
        if char ~= other._Head[i] then
            return false
        end
    end

    for i, char in ipairs(self._Body) do
        if char ~= other._Body[i] then
            return false
        end
    end

    for i, char in ipairs(self._Tail) do
        if char ~= other._Tail[i] then
            return false
        end
    end

    return true
end

---@private
function UUID:__tostring()
    local str = ""

    for _, char in ipairs(self._Head) do
        str = str .. string.char(char)
    end

    str = str .. "-"

    for _, char in ipairs(self._Body) do
        str = str .. string.char(char)
    end

    str = str .. "-"

    for _, char in ipairs(self._Tail) do
        str = str .. string.char(char)
    end

    return str
end

return Utils.Class.CreateClass(UUID, 'Core.UUID', require("Core.Json.Serializable"))
]]
}

PackageData["CoreEventEvent"] = {
    Location = "Core.Event.Event",
    Namespace = "Core.Event.Event",
    IsRunnable = true,
    Data = [[
---@class Core.Event : object
---@field private _Funcs Core.Task[]
---@field private _OnceFuncs Core.Task[]
---@operator len() : integer
---@overload fun() : Core.Event
local Event = {}

---@private
function Event:__init()
    self._Funcs = {}
    self._OnceFuncs = {}
end

---@param task Core.Task
---@return Core.Event
function Event:AddListener(task)
    table.insert(self._Funcs, task)
    return self
end

Event.On = Event.AddListener

---@param task Core.Task
---@return Core.Event
function Event:AddListenerOnce(task)
    table.insert(self._OnceFuncs, task)
    return self
end

Event.Once = Event.AddListenerOnce

---@param logger Core.Logger?
---@param ... any
function Event:Trigger(logger, ...)
    for _, task in ipairs(self._Funcs) do
        task:Execute(...)
    end

    for _, task in ipairs(self._OnceFuncs) do
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
    for _, task in ipairs(self._Funcs) do
        table.insert(permanentTask, task)
    end

    ---@type Core.Task[]
    local onceTask = {}
    for _, task in ipairs(self._OnceFuncs) do
        table.insert(onceTask, task)
    end
    return {
        Permanent = permanentTask,
        Once = onceTask
    }
end

---@return integer count
function Event:GetCount()
    return #self._Funcs + #self._OnceFuncs
end

---@param event Core.Event
---@return Core.Event event
function Event:CopyTo(event)
    for _, listener in ipairs(self._Funcs) do
        event:AddListener(listener)
    end
    for _, listener in ipairs(self._OnceFuncs) do
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
		if #event == 0 then
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

---@param timeoutSeconds number? in seconds
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
	self._Logger:LogDebug("event with signalName: '" .. eventPullData[1] .. "' was recieved")
	self.OnEventPull:Trigger(self._Logger, eventPullData)
	self:onEventPull(eventPullData)
	return true
end

--- Waits for all events in the event queue to be handled
---@param timeoutSeconds number? in seconds
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
---@field private _Path Core.FileSystem.Path
---@field private _Mode Core.FileSystem.File.OpenModes?
---@field private _File FIN.Filesystem.File?
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
        self._Path = Path(path)
        return
    end

    self._Path = path
end

---@return string
function File:GetPath()
    return self._Path:GetPath()
end

---@return boolean exists
function File:Exists()
    return filesystem.exists(self._Path:GetPath())
end

---@return boolean isOpen
---@nodiscard
function File:IsOpen()
    if not self._File then
        return false
    end

    return true
end

---@private
function File:CheckState()
    if not self:IsOpen() then
        error("file is not open: " .. self._Path:GetPath(), 3)
    end
end

---@param mode Core.FileSystem.File.OpenModes
---@return boolean isOpen
---@nodiscard
function File:Open(mode)
    local file

    if not filesystem.exists(self._Path:GetPath()) then
        local parentFolder = self._Path:GetParentFolder()
        if not filesystem.exists(parentFolder) then
            error("parent folder does not exist: " .. parentFolder)
        end

        if mode == "r" then
            file = filesystem.open(self._Path:GetPath(), "w")
            file:write("")
            file:close()
            file = nil
        end

        return false
    end

    self._File = filesystem.open(self._Path:GetPath(), mode)
    self._Mode = mode

    return true
end

---@param data string
function File:Write(data)
    self:CheckState()

    self._File:write(data)
end

---@param length integer
function File:Read(length)
    self:CheckState()

    return self._File:read(length)
end

---@param offset integer
function File:Seek(offset)
    self:CheckState()

    self._File:seek(offset)
end

function File:Close()
    self._File:close()
    self._File = nil
end

function File:Clear()
    local isOpen = self:IsOpen()
    if isOpen then
        self:Close()
    end

    if not filesystem.exists(self._Path:GetPath()) then
        return
    end

    filesystem.remove(self._Path:GetPath())

    local file = filesystem.open(self._Path:GetPath(), "w")
    file:write("")
    file:close()

    if isOpen then
        self._File = filesystem.open(self._Path:GetPath(), self._Mode)
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
---@field private _Nodes string[]
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
        self._Nodes = {}
        return
    end

    if type(pathOrNodes) == "string" then
        pathOrNodes = formatStr(pathOrNodes)
        self._Nodes = Utils.String.Split(pathOrNodes, "/")
        return
    end

    self._Nodes = pathOrNodes
end

---@return string path
function Path:GetPath()
    return Utils.String.Join(self._Nodes, "/")
end

---@private
Path.__tostring = Path.GetPath

---@return boolean
function Path:IsEmpty()
    return #self._Nodes == 0 or (#self._Nodes == 2 and self._Nodes[1] == "" and self._Nodes[2] == "")
end

---@return boolean
function Path:IsFile()
    return self._Nodes[#self._Nodes] ~= ""
end

---@return boolean
function Path:IsDir()
    return self._Nodes[#self._Nodes] == ""
end

---@return string
function Path:GetParentFolder()
    local copy = Utils.Table.Copy(self._Nodes)
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
    local lenght = #copy._Nodes

    if lenght > 0 then
        if lenght > 1 and copy._Nodes[lenght] == "" then
            copy._Nodes[lenght] = nil
            copy._Nodes[lenght - 1] = ""
        else
            copy._Nodes[lenght] = nil
        end
    end

    return copy
end

---@return string fileName
function Path:GetFileName()
    if not self:IsFile() then
        error("path is not a file: " .. self:GetPath())
    end

    return self._Nodes[#self._Nodes]
end

---@return string fileExtension
function Path:GetFileExtension()
    if not self:IsFile() then
        error("path is not a file: " .. self:GetPath())
    end

    local fileName = self._Nodes[#self._Nodes]

    local _, _, extension = fileName:find("^.+(%..+)$")
    return extension
end

---@return string fileStem
function Path:GetFileStem()
    if not self:IsFile() then
        error("path is not a file: " .. self:GetPath())
    end

    local fileName = self._Nodes[#self._Nodes]

    local _, _, stem = fileName:find("^(.+)%..+$")
    return stem
end

---@return Core.FileSystem.Path
function Path:Normalize()
    ---@type string[]
    local newNodes = {}

    for index, value in ipairs(self._Nodes) do
        if value == "." then
        elseif value == "" then
            if index == 1 or index == #self._Nodes then
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

    self._Nodes = newNodes
    return self
end

---@param path string
---@return Core.FileSystem.Path
function Path:Append(path)
    path = formatStr(path)
    local newNodes = Utils.String.Split(path, "/")

    for _, value in ipairs(newNodes) do
        self._Nodes[#self._Nodes + 1] = value
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
    local copyNodes = Utils.Table.Copy(self._Nodes)
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
---@field private _TypeInfos Dictionary<string, Utils.Class.Type>
---@overload fun(typeInfos: Utils.Class.Type[]?) : Core.Json.Serializer
local JsonSerializer = {}

---@type Core.Json.Serializer
JsonSerializer.Static__Serializer = Utils.Class.Placeholder

---@private
---@param typeInfos Utils.Class.Type[]?
function JsonSerializer:__init(typeInfos)
    self._TypeInfos = {}

    for _, typeInfo in ipairs(typeInfos or {}) do
        self._TypeInfos[typeInfo.Name] = typeInfo
    end
end

function JsonSerializer:AddTypesFromStatic()
    for name, typeInfo in pairs(self.Static__Serializer._TypeInfos) do
        if not Utils.Table.ContainsKey(self._TypeInfos, name) then
            self._TypeInfos[name] = typeInfo
        end
    end
end

---@param typeInfo Utils.Class.Type
---@return Core.Json.Serializer
function JsonSerializer:AddTypeInfo(typeInfo)
    if not Utils.Class.HasBaseClass("Core.Json.Serializable", typeInfo) then
        error("class type has not Core.Json.Serializable as base class", 2)
    end
    if not Utils.Table.ContainsKey(self._TypeInfos, typeInfo.Name) then
        self._TypeInfos[typeInfo.Name] = typeInfo
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

---@private
---@param class object
---@return table data
function JsonSerializer:serializeClass(class)
    local typeInfo = class:Static__GetType()
    if not Utils.Class.HasBaseClass("Core.Json.Serializable", typeInfo) then
        error("can not serialize class: " .. typeInfo.Name .. " use 'Core.Json.Serializable' as base class")
    end
    ---@cast class Core.Json.Serializable

    local data = { __Type = typeInfo.Name, __Data = { class:Serialize() } }

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

    if Utils.Class.IsClass(obj) then
        ---@cast obj object
        return self:serializeClass(obj)
    end

    for key, value in next, obj, nil do
        if type(value) == "table" then
            obj[key] = self:serializeInternal(value)
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

    local typeInfo = self._TypeInfos[t.__Type]
    if not typeInfo then
        error("unable to find typeInfo for class: " .. t.__Type)
    end

    ---@type Core.Json.Serializable
    local classTemplate = typeInfo.Template

    if type(data) == "table" then
        for key, value in next, data, nil do
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

Utils.Class.CreateClass(JsonSerializer, "Core.Json.JsonSerializer")

JsonSerializer.Static__Serializer = JsonSerializer()
JsonSerializer.Static__Serializer:AddTypeInfos({
    -- UUID
    require("Core.UUID"):Static__GetType()
})

return JsonSerializer
]]
}

PackageData["CoreJsonSerializable"] = {
    Location = "Core.Json.Serializable",
    Namespace = "Core.Json.Serializable",
    IsRunnable = true,
    Data = [[
---@class Core.Json.Serializable : object
local Serializable = {}

---@return any ...
function Serializable:Serialize()
    return tostring(self)
end

---@param ... any
---@return any obj
function Serializable:Static__Deserialize(...)
    return self(...)
end

return Utils.Class.CreateClass(Serializable, "Core.Json.Serializable")
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
    FactoryControl = "FactoryControl"
}

return EventNameUsage
]]
}

PackageData["CoreUsageUsage_Port"] = {
    Location = "Core.Usage.Usage_Port",
    Namespace = "Core.Usage.Usage_Port",
    IsRunnable = true,
    Data = [[
-- 0 .. 2^1023

---@enum Core.PortUsage
local PortUsage = {
	Heartbeats = 10,
	DNS = 53,
	HTTP = 80,
	FactoryControl = 12500,
}

return PortUsage
]]
}

PackageData["CoreUsageUsage"] = {
    Location = "Core.Usage.Usage",
    Namespace = "Core.Usage.Usage",
    IsRunnable = true,
    Data = [[
return {
    Ports = require("Core.Usage.Usage_Port"),
    Events = require("Core.Usage.Usage_EventName")
}
]]
}

return PackageData
