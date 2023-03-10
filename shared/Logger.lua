local Logger = {}
Logger.__index = Logger

function Logger.new(name, logLevel, path)
    local instance = setmetatable({}, Logger)
    instance.LogLevel = logLevel
    instance.Name = name
    instance.Path = path
    return instance
end

Logger.LogLevel = 0
Logger.Name = ""
Logger.Path = nil

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

function Logger:LogDebug(message)
    if self.LogLevel == 0 then
        self:Log("DEBUG! "..message)
    end
end

function Logger:LogInfo(message)
    if self.LogLevel <= 1 then
        self:Log("INFO! "..message)
    end
end

function Logger:LogError(message)
    if self.LogLevel <= 2 then
        self:Log("ERROR! "..message)
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