local Logger = {}
Logger.__index = Logger

Logger.LogLevel = 0
Logger.Name = ""
Logger.Path = nil

function Logger.new(name, logLevel, path)
    local instance = setmetatable({}, Logger)
    instance.LogLevel = logLevel
    instance.Name = name
    instance.Path = path
    return instance
end

function Logger:create(name, path)
    local instance = setmetatable({}, Logger)
    instance.LogLevel = self.LogLevel
    instance.Name = self.Name.."."..name
    instance.Path = path
    return instance
end

function Logger:Log(message)
    message = "["..self.Name.."] "..message

    if self.Path ~= nil then
       local ownFile = filesystem.open(self.Path, "+a")
       ownFile:write(message.."\n")
       ownFile:close()
    end

    local file = filesystem.open("log\\Log.txt", "+a")
    file:write(message.."\n")
    file:close()
    print(message)
end

function Logger:LogTable(table, indent, logLevel)
    if not indent then indent = 0 end
    for k, v in pairs(table) do
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            self:Log(logLevel..formatting)
            self:LogTable(v, indent+1)
        else
            self:Log(logLevel .. formatting .. tostring(v))
        end
    end
end

function Logger:LogDebug(message)
    if message == nil then return end
    if self.LogLevel == 0 then
        self:Log("DEBUG! "..message)
    end
end

function Logger:LogTableDebug(table)
    if table == nil or type(table) ~= "table" then return end
    if self.LogLevel == 0 then
        self:LogTable(table, 0, "DEBUG! ")
    end
end

function Logger:LogInfo(message)
    if message == nil then return end
    if self.LogLevel <= 1 then
        self:Log("INFO! "..message)
    end
end

function Logger:LogTableInfo(table)
    if table == nil or type(table) ~= "table" then return end
    if self.LogLevel <= 1 then
        self:LogTable(table, 0, "INFO! ")
    end
end

function Logger:LogError(message)
    if message == nil then return end
    if self.LogLevel <= 2 then
        self:Log("ERROR! "..message)
    end
end

function Logger:LogTableError(table)
    if table == nil or type(table) ~= "table" then return end
    if self.LogLevel <= 2 then
        self:LogTable(table, 0, "ERROR! ")
    end
end

function Logger:ClearLog()
    if self.Path ~= nil then
        local ownFile = filesystem.open(self.Path, "w")
        ownFile:write("")
        ownFile:close()
    end
end

return Logger