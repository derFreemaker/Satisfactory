local PackageData = {}

-- ########## Core ##########

-- ########## Core.Event ##########

PackageData.oVIzFPpX = {
    Namespace = "Core.Event.Event",
    Name = "Event",
    FullName = "Event.lua",
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

---@private
---@return integer count
function Event:__len()
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

PackageData.PksKdJNx = {
    Namespace = "Core.Event.EventPullAdapter",
    Name = "EventPullAdapter",
    FullName = "EventPullAdapter.lua",
    IsRunnable = true,
    Data = [[
local Event = require("Core.Event.Event")

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

---@param timeout number?
---@return boolean gotEvent
function EventPullAdapter:Wait(timeout)
    self.logger:LogTrace("## waiting for event pull ##")
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
    self.logger:LogDebug("event with signalName: '".. eventPullData[1] .."' was recieved")
    self.OnEventPull:Trigger(self.logger, eventPullData)
    self:onEventPull(eventPullData)
    return true
end

function EventPullAdapter:Run()
    self.logger:LogDebug("## started event pull loop ##")
    while true do
        self:Wait()
    end
end

return EventPullAdapter
]]
}

-- ########## Core.Event ########## --

PackageData.qzdVACkX = {
    Namespace = "Core.Json",
    Name = "Json",
    FullName = "Json.lua",
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
local json = { _version = "0.1.2" }

-------------------------------------------------------------------------------
-- Encode
-------------------------------------------------------------------------------

local encode

local escape_char_map = {
    ["\\"] = "\\",
    ["\""] = "\"",
    ["\b"] = "b",
    ["\f"] = "f",
    ["\n"] = "n",
    ["\r"] = "r",
    ["\t"] = "t",
}

local escape_char_map_inv = { ["/"] = "/" }
for k, v in pairs(escape_char_map) do
    escape_char_map_inv[v] = k
end


local function escape_char(c)
    return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
end


local function encode_nil(val)
    return "null"
end


local function encode_table(val, stack)
    local res = {}
    stack = stack or {}

    -- Circular reference?
    if stack[val] then error("circular reference") end

    stack[val] = true

    if rawget(val, 1) ~= nil or next(val) == nil then
        -- Treat as array -- check keys are valid and it is not sparse
        local n = 0
        for k in pairs(val) do
            if type(k) ~= "number" then
                error("invalid table: mixed or invalid key types")
            end
            n = n + 1
        end
        if n ~= #val then
            error("invalid table: sparse array")
        end
        -- Encode
        for i, v in ipairs(val) do
            table.insert(res, encode(v, stack))
        end
        stack[val] = nil
        return "[" .. table.concat(res, ",") .. "]"
    else
        -- Treat as an object
        for k, v in pairs(val) do
            if type(k) ~= "string" then
                error("invalid table: mixed or invalid key types")
            end
            table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
        end
        stack[val] = nil
        return "{" .. table.concat(res, ",") .. "}"
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
    return string.format("%.14g", val)
end


local type_func_map = {
    ["nil"] = encode_nil,
    ["table"] = encode_table,
    ["string"] = encode_string,
    ["number"] = encode_number,
    ["boolean"] = tostring,
}


encode = function(val, stack)
    local t = type(val)
    local f = type_func_map[t]
    if f then
        return f(val, stack)
    end
    error("unexpected type '" .. t .. "'")
end


---@param val any
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
    for i = 1, select("#", ...) do
        res[select(i, ...)] = true
    end
    return res
end

local space_chars  = create_set(" ", "\t", "\r", "\n")
local delim_chars  = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
local literals     = create_set("true", "false", "null")

local literal_map  = {
    ["true"] = true,
    ["false"] = false,
    ["null"] = nil,
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
        if str:sub(i, i) == "\n" then
            line_count = line_count + 1
            col_count = 1
        end
    end
    error(string.format("%s at line %d col %d", msg, line_count, col_count))
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
        return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
            f(n % 4096 / 64) + 128, n % 64 + 128)
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
    local res = ""
    local j = i + 1
    local k = j

    while j <= #str do
        local x = str:byte(j)

        if x < 32 then
            decode_error(str, j, "control character in string")
        elseif x == 92 then -- `\`: Escape
            res = res .. str:sub(k, j - 1)
            j = j + 1
            local c = str:sub(j, j)
            if c == "u" then
                local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
                    or str:match("^%x%x%x%x", j + 1)
                    or decode_error(str, j - 1, "invalid unicode escape in string")
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

    decode_error(str, i, "expected closing quote for string")
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
        if str:sub(i, i) == "]" then
            i = i + 1
            break
        end
        -- Read token
        x, i = parse(str, i)
        res[n] = x
        n = n + 1
        -- Next token
        i = next_char(str, i, space_chars, true)
        local chr = str:sub(i, i)
        i = i + 1
        if chr == "]" then break end
        if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
    end
    return res, i
end


local function parse_object(str, i)
    local res = {}
    i = i + 1
    while 1 do
        local key, val
        i = next_char(str, i, space_chars, true)
        -- Empty / end of object?
        if str:sub(i, i) == "}" then
            i = i + 1
            break
        end
        -- Read key
        if str:sub(i, i) ~= '"' then
            decode_error(str, i, "expected string for key")
        end
        key, i = parse(str, i)
        -- Read ':' delimiter
        i = next_char(str, i, space_chars, true)
        if str:sub(i, i) ~= ":" then
            decode_error(str, i, "expected ':' after key")
        end
        i = next_char(str, i + 1, space_chars, true)
        -- Read value
        val, i = parse(str, i)
        -- Set
        res[key] = val
        -- Next token
        i = next_char(str, i, space_chars, true)
        local chr = str:sub(i, i)
        i = i + 1
        if chr == "}" then break end
        if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
    end
    return res, i
end


local char_func_map = {
    ['"'] = parse_string,
    ["0"] = parse_number,
    ["1"] = parse_number,
    ["2"] = parse_number,
    ["3"] = parse_number,
    ["4"] = parse_number,
    ["5"] = parse_number,
    ["6"] = parse_number,
    ["7"] = parse_number,
    ["8"] = parse_number,
    ["9"] = parse_number,
    ["-"] = parse_number,
    ["t"] = parse_literal,
    ["f"] = parse_literal,
    ["n"] = parse_literal,
    ["["] = parse_array,
    ["{"] = parse_object,
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
---@return any
function json.decode(str)
    if type(str) ~= "string" then
        error("expected argument of type string, got " .. type(str))
    end
    local res, idx = parse(str, next_char(str, 1, space_chars, true))
    idx = next_char(str, idx, space_chars, true)
    if idx <= #str then
        decode_error(str, idx, "trailing garbage")
    end
    return res
end

return json
]]
}

PackageData.RONgYwHx = {
    Namespace = "Core.Logger",
    Name = "Logger",
    FullName = "Logger.lua",
    IsRunnable = true,
    Data = [[
local Event = require("Core.Event.Event")

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
            for p in string.gmatch(properties, "%b{}") do
                local propName = string.sub(p, 2, -2)
                for k in string.gmatch(propName, "[^,%s]+") do
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
                local childLines = tableToLineTree(node[k], maxLevel, properties, level + 1, padding .. (i == #keys and '    ' or '│   '))
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
    self.Name = (string.gsub(name, " ", "_") or "")
    self.OnLog = onLog or Event()
    self.OnClear = onClear or Event()
end

---@param name string
---@return Core.Logger
function Logger:subLogger(name)
    name = self.Name .. "." .. name
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

    message = "[" .. self.Name .. "] " .. message
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

    if t == nil or type(t) ~= "table" then return end
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

    self.OnLog:Trigger(self, "")
end

---@param message any
function Logger:LogTrace(message)
    if message == nil then return end
    self:Log("TRACE " .. tostring(message), 0)
end

---@param message any
function Logger:LogDebug(message)
    if message == nil then return end
    self:Log("DEBUG " .. tostring(message), 1)
end

---@param message any
function Logger:LogInfo(message)
    if message == nil then return end
    self:Log("INFO " .. tostring(message), 2)
end

---@param message any
function Logger:LogWarning(message)
    if message == nil then return end
    self:Log("WARN " .. tostring(message), 3)
end

---@param message any
function Logger:LogError(message)
    if message == nil then return end
    self:Log("ERROR " .. tostring(message), 4)
end

return Utils.Class.CreateClass(Logger, "Core.Logger")
]]
}

PackageData.seyrvpeX = {
    Namespace = "Core.Path",
    Name = "Path",
    FullName = "Path.lua",
    IsRunnable = true,
    Data = [[
---@class Core.Path
---@field private path string
---@overload fun(path: string?) : Core.Path
local Path = {}

---@param path string
---@boolean
function Path.Static__IsNode(path)
    if path:find("/") then
        return false
    end
    if path:find("\\") then
        return false
    end
    if path:find("|") then
        return false
    end
    return true
end

---@private
---@param path string?
function Path:__init(path)
    if not path or path == "" then
        self.path = ""
        return
    end
    self.path = path:gsub("\\", "/")
end

---@return string
function Path:GetPath()
    return self.path
end

---@param node string
---@return Core.Path
function Path:Append(node)
    local pos = self.path:len() - self.path:reverse():find("/")
    if node == "." or node == ".." or Path.Static__IsNode(node) then
        if pos ~= self.path:len() - 1 then
            self.path = self.path .. "/"
        end
        self.path = self.path .. node
    elseif node == "/" then
        self.path = self.path .. node
    end
    return self
end

---@return string
function Path:GetRoot()
    local str = self:Relative().path
    local slash = str:find("/")
    return str:sub(0, slash)
end

---@return Core.Path
function Path:GetParentFolderPath()
    local pos = self.path:reverse():find("/")
    if not pos then
        return Path()
    end
    local path = self.path:sub(0, self.path:len() - pos)
    return Path(path)
end

---@return boolean
function Path:IsSingle()
    local pos = self.path:find("/", 1)
    return (pos == 0 and self.path:len() > 0 and self.path ~= "/")
end

---@return boolean
function Path:IsAbsolute()
    return self.path:sub(0, 1) == "/"
end

---@return boolean
function Path:IsEmpty()
    return (self.path:len() == 1 and self:IsAbsolute()) or self.path:len() == 0
end

---@return boolean
function Path:IsRoot()
    return self.path == "/"
end

---@return boolean
function Path:IsDir()
    local reversedPath = self.path:reverse()
    return reversedPath:sub(0, 1) == "/"
end

---@param other Core.Path
---@return boolean
function Path:StartsWith(other)
    if other:IsAbsolute() then
        other = other:Absolute()
    else
        other = other:Relative()
    end
    return self.path:sub(0, other.path:len()) == other.path
end

---@return string
function Path:GetFileName()
    local slash = (self.path:reverse():find("/") or 0) - 2
    if slash == nil or slash == -2 then
        return self.path
    end
    return self.path:sub(self.path:len() - slash)
end

---@return string
function Path:GetFileExtension()
    local name = self:GetFileName()
    local pos = (name:reverse():find("%.") or 0) - 1
    if pos == nil or pos == -1 then
        return ""
    end
    return name:sub(name:len() - pos)
end

---@return string
function Path:GetFileStem()
    local name = self:GetFileName()
    local pos = (name:reverse():find("%.") or 0)
    local lenght = name:len()
    if pos == lenght then
        return name
    end
    return name:sub(0, lenght - pos)
end

---@return Core.Path
function Path:Normalize()
    local newPath = Path()
    if self:IsAbsolute() then
        newPath.path = "/"
    end
    local posStart = 0
    local posEnd = self.path:find("/", posStart)
    while true do
        local node = self.path:sub(posStart, posEnd - 1)
        posStart = posEnd + 1
        if node == "." then
        elseif node == ".." then
            local pos = newPath.path:len() - newPath.path:reverse():find("/")
            if pos == nil then
                newPath.path = ""
            else
                newPath.path = newPath.path:sub(pos)
            end
            if newPath.path:len() < 1 and self:IsAbsolute() then
                newPath.path = "/"
            end
        elseif Path.Static__IsNode(node) then
            if newPath.path:len() > 0 and newPath.path:reverse():find("/") ~= 1 then
                newPath.path = newPath.path .. "/"
            end
            newPath.path = newPath.path .. node
        end

        if posEnd == self.path:len() + 1 then
            break
        end

        local newPosEnd = self.path:find("/", posStart)
        if newPosEnd == nil then
            posStart = posEnd + 1
            newPosEnd = self.path:len() + 1
        end
        posEnd = newPosEnd
    end
    return newPath
end

---@return Core.Path
function Path:Absolute()
    if self:IsAbsolute() then
        return Path(self:Normalize().path)
    end
    return Path("/" .. self:Normalize().path)
end

---@return Core.Path
function Path:Relative()
    if self:IsAbsolute() then
        return Path(self:Normalize().path:sub(1))
    end
    return self:Normalize()
end

---@param pathExtension string
---@return Core.Path
function Path:Extend(pathExtension)
    local path = self.path
    local pos = path:len() - path:reverse():find("/")
    if pathExtension == "." or pathExtension == ".." or Path.Static__IsNode(pathExtension) then
        if pos ~= path:len() - 1 then
            path = path .. "/"
        end
        path = path .. pathExtension
    elseif pathExtension == "/" then
        path = path .. pathExtension
    end
    return Path(path)
end

function Path:Copy()
    return Path(self.path)
end

return Utils.Class.CreateClass(Path, "Core.Path")
]]
}

PackageData.TtiCTjCx = {
    Namespace = "Core.Task",
    Name = "Task",
    FullName = "Task.lua",
    IsRunnable = true,
    Data = [[
---@class Core.Task : object
---@field package func function
---@field package passthrough table
---@field package thread thread
---@field package closed boolean
---@field private success boolean
---@field private results any[]
---@field private traceback string?
---@overload fun(func: function, passthrough: table?) : Core.Task
local Task = {}

---@private
---@param func function
---@param passthrough table
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

---@return string traceback
function Task:Traceback()
    if self.traceback ~= nil then
        return self.traceback end
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

-- ########## Core ########## --

return PackageData
