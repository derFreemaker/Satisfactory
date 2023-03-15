local Logger = {}
Logger.__index = Logger

function Logger.new(name, logLevel, path)
    if not filesystem.exists("log") then filesystem.createDir("log") end
    local instance = {
        LogLevel = (logLevel or 0),
        Name = (string.gsub(name, " ", "_") or ""),
        Path = (path or nil)
    }
    instance = setmetatable(instance, Logger)
    return instance
end

function Logger:create(name, path)
    return Logger.new(self.Name.."."..name, self.LogLevel, path)
end

function Logger:Log(message, logLevel)
    message = "["..self.Name.."] "..message

    if self.Path ~= nil then
       local ownFile = filesystem.open(self.Path, "+a")
       ownFile:write(message.."\n")
       ownFile:close()
    end

    local file = filesystem.open("log\\Log.txt", "+a")
    file:write(message.."\n")
    file:close()
    if logLevel >= self.LogLevel then
        print(message)
    end
end

function Logger:LogTable(table, indent, logLevelString, logLevel)
    if logLevelString == nil then return end
    if not indent then indent = 0 end
    for k, v in pairs(table) do
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" and k ~= "__index" then
            self:Log(logLevelString..formatting, logLevel)
            self:LogTable(v, indent+1, logLevelString, logLevel)
        else
            self:Log(logLevelString .. formatting .. tostring(v), logLevel)
        end
    end
end

function Logger:LogTrace(message)
    if message == nil then return end
    self:Log("TRACE! "..message, 0)
end

function Logger:LogTableTrace(table)
    if table == nil or type(table) ~= "table" then return end
    self:LogTable(table, 0, "TRACE! ", 0)
end


function Logger:LogDebug(message)
    if message == nil then return end
    self:Log("DEBUG! "..message, 1)
end

function Logger:LogTableDebug(table)
    if table == nil or type(table) ~= "table" then return end
    self:LogTable(table, 0, "DEBUG! ", 1)
end


function Logger:LogInfo(message)
    if message == nil then return end
    self:Log("INFO! "..message, 2)
end

function Logger:LogTableInfo(table)
    if table == nil or type(table) ~= "table" then return end
    self:LogTable(table, 0, "INFO! ", 2)
end


function Logger:LogError(message)
    if message == nil then return end
    self:Log("ERROR! "..message, 3)
end

function Logger:LogTableError(table)
    if table == nil or type(table) ~= "table" then return end
    self:LogTable(table, 0, "ERROR! ", 3)
end


function Logger:ClearLog(clearMainFile)
    if self.Path ~= nil then
        local ownFile = filesystem.open(self.Path, "w")
        ownFile:write("")
        ownFile:close()
    end

    if clearMainFile then
        local mainFile = filesystem.open("log\\Log.txt", "w")
        mainFile:write("")
        mainFile:close()
    end
end

return Logger