local LoadedLoaderFiles = ({ ... })[1]
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
---|10 Write

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

---@param message string
---@param logLevel Github_Loading.Logger.LogLevel
function Logger:Log(message, logLevel)
    if logLevel < self.LogLevel then
        return
    end

    message = "[" .. self.Name .. "] " .. tostring(message)
    self.OnLog:Trigger(nil, message)
end

---@param t table
---@param logLevel Github_Loading.Logger.LogLevel
---@param maxLevel integer?
---@param properties string[]?
function Logger:LogTable(t, logLevel, maxLevel, properties)
    if logLevel < self.LogLevel then
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

---@param logLevel Github_Loading.Logger.LogLevel
function Logger:FreeLine(logLevel)
    if logLevel < self.LogLevel then
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

return Logger
