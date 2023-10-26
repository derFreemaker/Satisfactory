local LoadedLoaderFiles = ({ ... })[1]
---@type Utils
local Utils = LoadedLoaderFiles["/Github-Loading/Loader/Utils"][1]
---@type Github_Loading.Event
local Event = LoadedLoaderFiles["/Github-Loading/Loader/Event"][1]

---@alias Github_Loading.Logger.LogLevel
---|1 Trace
---|2 Debug
---|3 Info
---|4 Warning
---|5 Error
---|6 Fatal
---|10 Write (will only write content no information like normal a log)

---@enum Github_Loading.Logger.LogLevel.ToName
local LogLevelToName = {
    [1] = "Trace",
    [2] = "Debug",
    [3] = "Info",
    [4] = "Warning",
    [5] = "Error",
    [6] = "Fatal",
    [10] = "Write"
}

---@class Github_Loading.Logger
---@field OnLog Github_Loading.Event
---@field OnClear Github_Loading.Event
---@field Name string
---@field LogLevel number
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

---@param name string
---@param logLevel Github_Loading.Logger.LogLevel
---@return Github_Loading.Logger
function Logger.new(name, logLevel)
    return setmetatable({
        LogLevel = logLevel,
        Name = (string.gsub(name, " ", "_") or ""),
        OnLog = Event.new(),
        OnClear = Event.new()
    }, { __index = Logger })
end

---@param name string
---@return Github_Loading.Logger
function Logger:subLogger(name)
    name = self.Name .. "." .. name
    return setmetatable({
        LogLevel = self.LogLevel,
        Name = name:gsub(" ", "_"),
        OnLog = Utils.Table.Copy(self.OnLog),
        OnClear = Utils.Table.Copy(self.OnClear)
    }, { __index = Logger })
end

---@param logger Github_Loading.Logger
---@return Github_Loading.Logger logger
function Logger:CopyListenersTo(logger)
    self.OnLog:CopyTo(logger.OnLog)
    self.OnClear:CopyTo(logger.OnClear)
    return logger
end

---@param Task Core.Task | fun(func: function, parent: table?) : Core.Task
---@param logger Core.Logger
---@return Core.Logger logger
function Logger:CopyListenersToCoreEvent(Task, logger)
    self.OnLog:CopyToCoreEvent(Task, logger.OnLog)
    self.OnClear:CopyToCoreEvent(Task, logger.OnClear)
    return logger
end

---@param obj any
---@return string messagePart
local function formatMessagePart(obj)
    if obj == nil then
        return "nil"
    end

    if type(obj) == "table" then
        local str

        ---@type Out<Utils.Class.Metatable>
        local metatableOut = {}
        if Utils.Class.IsClass(obj, metatableOut) then
            local typeInfo = metatableOut.Value.Type
            str = typeInfo.Name
        else
            str = tostring(obj)
        end

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
    if logLevel < self.LogLevel then
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
    if logLevel < self.LogLevel then
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
    if logLevel < self.LogLevel then
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

return Logger
