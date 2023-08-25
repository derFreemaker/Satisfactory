local Event = require("Core.Event.Event")

---@alias Core.Logger.LogLevel
---|0 Trace
---|1 Debug
---|2 Info
---|3 Warning
---|4 Error

---@class Core.Logger : object
---@field OnLog Core.Event
---@field OnClear Core.Event
---@field Name string
---@field LogLevel Core.Logger.LogLevel
---@overload fun(name: string, logLevel: Core.Logger.LogLevel, onLog: Core.Event?, onClear: Core.Event?) : Core.Logger
local Logger = {}

---@param node table
---@param maxLevel integer?
---@param properties string[]?
---@param logFunc function
---@param logFuncParent table
---@param level integer?
---@param padding string?
---@return string[]
local function tableToLineTree(node, maxLevel, properties, logFunc, logFuncParent, level, padding)
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
                local childLines = tableToLineTree(node[k], maxLevel, properties, logFunc, logFuncParent, level + 1, padding .. (i == #keys and '    ' or '│   '))
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
        if logFuncParent == nil then
            for line in pairs(lines) do
                logFunc(line)
            end
        elseif type(logFuncParent) ~= "table" then
            error("logFuncParent was not a table", 2)
        else
            for line in pairs(lines) do
                logFunc(logFuncParent, line)
            end
        end
    end

    return lines
end

---@private
---@param name string
---@param logLevel Core.Logger.LogLevel
---@param onLog Core.Event?
---@param onClear Core.Event?
function Logger:Logger(name, logLevel, onLog, onClear)
    self.LogLevel = logLevel
    self.Name = (string.gsub(name, " ", "_") or "")
    self.OnLog = onLog or Event()
    self.OnClear = onClear or Event()
end

---@param name string
---@return Core.Logger
function Logger:subLogger(name)
    name = self.Name .. "." .. name
    local logger = Logger(name, self.LogLevel)
    return self:CopyListenersTo(logger)
end

---@param logger Core.Logger
---@return Core.Logger logger
function Logger:CopyListenersTo(logger)
    self.OnLog:CopyTo(logger.OnLog)
    self.OnClear:CopyTo(logger.OnClear)
    return logger
end

---@private
---@param message string
---@param logLevel Core.Logger.LogLevel
function Logger:Log(message, logLevel)
    if logLevel < self.LogLevel then
        return
    end

    message = "[" .. self.Name .. "] " .. message
    self.OnLog:Trigger(message)
end

---@param t table
---@param logLevel Core.Logger.LogLevel
---@param maxLevel integer?
---@param properties string[]?
function Logger:LogTable(t, logLevel, maxLevel, properties)
    if logLevel < self.LogLevel then
        return
    end

    if t == nil or type(t) ~= "table" then return end
    local function log(message) self:Log(message, logLevel) end
    tableToLineTree(t, maxLevel, properties, log, self)
end

function Logger:Clear()
    self.OnClear:Trigger()
end

---@param logLevel Github_Loading.Logger.LogLevel
function Logger:FreeLine(logLevel)
    self:Log("", logLevel)
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


function Logger:setErrorLogger()
    _G.__errorLogger = self
end

return Utils.Class.CreateClass(Logger, "Logger")