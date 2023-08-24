local LoadedLoaderFiles = table.pack(...)[1]
---@type Utils
local Utils = LoadedLoaderFiles["/Github-Loading/Loader/Utils"][1]
---@type Github_Loading.Event
local Event = LoadedLoaderFiles["/Github-Loading/Loader/Event"][1]
---@type Github_Loading.Listener
local Listener = LoadedLoaderFiles["/Github-Loading/Loader/Listener"][1]

---@alias Github_Loading.Logger.LogLevel
---|0 Trace
---|1 Debug
---|2 Info
---|3 Warning
---|4 Error

---@class Github_Loading.Logger
---@field OnLog Github_Loading.Event
---@field OnClear Github_Loading.Event
---@field Name string
---@field LogLevel number
local Logger = {}

---@private
---@param node table
---@param maxLevel number?
---@param properties string[]?
---@param logFunc Github_Loading.Listener
---@param level number?
---@param padding string?
---@return string[]
function Logger.tableToLineTree(node, maxLevel, properties, logFunc, level, padding)
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
                local childLines = Logger.tableToLineTree(node[k], maxLevel, properties, logFunc,
                    level + 1,
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

    if level == 1 then
        for line in pairs(lines) do
            logFunc:Execute(line)
        end
    end

    return lines
end

---@param name string
---@param logLevel Github_Loading.Logger.LogLevel
---@return Github_Loading.Logger
function Logger.new(name, logLevel)
    local metatable = {
        __index = Logger
    }
    return setmetatable({
        LogLevel = logLevel,
        Name = (string.gsub(name, " ", "_") or ""),
        OnLog = Event.new(),
        OnClear = Event.new()
    }, metatable)
end

---@param name string
---@return Github_Loading.Logger
function Logger:subLogger(name)
    name = self.Name .. "." .. name
    local metatable = {
        __index = Logger
    }
    return setmetatable({
        LogLevel = self.LogLevel,
        Name = name:gsub(" ", "_"),
        OnLog = Utils.Table.Copy(self.OnLog),
        OnClear = Utils.Table.Copy(self.OnClear)
    }, metatable)
end

---@param logger Github_Loading.Logger | Core.Logger
---@return Github_Loading.Logger | Core.Logger logger
function Logger:CopyListenersTo(logger)
    self.OnLog:CopyTo(logger.OnLog)
    self.OnClear:CopyTo(logger.OnClear)
    return logger
end

---@private
---@param message string
---@param logLevel Github_Loading.Logger.LogLevel
function Logger:Log(message, logLevel)
    if logLevel < self.LogLevel then
        return
    end

    message = "[" .. self.Name .. "] " .. tostring(message)
    self.OnLog:Trigger(message)
end

---@param t table
---@param logLevel Github_Loading.Logger.LogLevel
---@param maxLevel number?
---@param properties table?
function Logger:LogTable(t, logLevel, maxLevel, properties)
    if table == nil or type(table) ~= "table" then return end
    local function log(message) self:Log(message, logLevel) end
    Logger.tableToLineTree(table, maxLevel, properties, Listener.new(log, self))
end

function Logger:Clear()
    self.OnClear:Trigger()
end

function Logger:FreeLine()
    self:Log("", 4)
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


---@param logger Github_Loading.Logger
function Logger.setErrorLogger(logger)
    _G.__errorLogger = logger
end

local errorFunc = error
---@param message string
---@param level integer?
function error(message, level)
    message = message or "no error message"
    level = level or 1
    level = level + 1
    if __errorLogger then
        local debugInfo = debug.getinfo(level)
        local errorMessage = debugInfo.short_src .. ":" .. debugInfo.currentline .. ": " .. message
        errorMessage = debug.traceback(errorMessage, level + 1)
        pcall(_G.__errorLogger.LogError, _G.__errorLogger, errorMessage)
    end
    return errorFunc(message, level)
end

local asserFunc = assert
---@generic T
---@param condition T
---@param message? any
---@param ... any
---@return T, any ...
function assert(condition, message, ...)
    message = message or "assertation failed"
    if not condition and __errorLogger then
        local debugInfo = debug.getinfo(2)
        local errorMessage = debugInfo.short_src .. ":" .. debugInfo.currentline .. ": " .. message
        errorMessage = debug.traceback(errorMessage, 3)
        pcall(_G.__errorLogger.LogError, _G.__errorLogger, errorMessage)
    end
    return asserFunc(condition, message, ...)
end

local panicFunc = computer.panic
---@param errorMsg string
function computer.panic(errorMsg) ---@diagnostic disable-line
    if __errorLogger then
        local debugInfo = debug.getinfo(2)
        local errorMessage = "PANIC!: " .. debugInfo.short_src .. ":" .. debugInfo.currentline .. ": " .. errorMsg
        errorMessage = debug.traceback(errorMessage, 3)
        pcall(_G.__errorLogger.LogError, _G.__errorLogger, errorMessage)
    end
    return panicFunc(errorMsg)
end

return Logger