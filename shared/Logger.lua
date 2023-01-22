local Logger = {}
Logger.__index = Logger

function Logger.new(name, debug, path)
    local instace = setmetatable({}, Logger)
    if debug == true then
        instace.debug = debug
    end
    instace.Name = name
    instace.path = path
    return instace
end

Logger.debug = false
Logger.Name = ""
Logger.path = nil

function Logger:Log(message)
    message = "["..self.Name.."] "..message

    if self.path ~= nil then
       local ownFile = filesystem.open(self.path, "+a")
       ownFile:write(message.."\n")
       ownFile:close()
    end

    local file = filesystem.open("log\\Log.txt", "+a")
    file:write(message.."\n")
    file:close()
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

function Logger:ClearLog()
    if self.path ~= nil then
        local ownFile = filesystem.open(self.path, "w")
        ownFile:write("")
        ownFile:close()
    end

    local file = filesystem.open("log\\Log.txt", "w")
    file:write("")
    file:close()
end

return Logger