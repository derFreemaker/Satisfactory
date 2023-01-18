local Logger = {}
Logger.__index = Logger

function Logger.new(name, debug)
    local instace = setmetatable({}, Logger)
    if debug == true then
        instace.debug = debug
    end
    instace.Name = name
    instace.file = filesystem.open("log\\Log.txt", "+a")
    instace.file:write("\n["..name.."] STARTED LOGGING\n")
    return instace
end

Logger.debug = false
Logger.Name = ""
Logger.file = {}

function Logger:Log(message)
    message = "["..self.Name.."] "..message
    self.file:write(message.."\n")
    print(message)
end

function Logger:LogDebug(message)
    if self.debug then
        self:Log("DEBUG! "..message)
    end
end

function Logger:LogInfo(message)
    self:Log("INFO! "..message)
end

function Logger:LogError(message)
    self:Log("ERROR! "..message)
end

return Logger