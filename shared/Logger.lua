local Logger = {}
Logger.__index = Logger

function Logger.new(logFilePath, debug)
    local instace = setmetatable({}, Logger)
    if debug == true then
        instace.debug = debug
    end
    instace.logFilePath = logFilePath
    return instace
end

Logger.debug = false
Logger.logFilePath = ""

function Logger:Log(message)
    print(message)
end

function Logger:LogDebug(message)
    self:Log("DEBUG! "..message)
end

function Logger:LogInfo(message)
    self:Log("INFO! "..message)
end

function Logger:LogError(message)
    self:Log("ERROR! "..message)
end

return Logger