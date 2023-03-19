Utils = {}

local _logger = {}

function Utils.Initialize(logger)
    _logger = logger
end

function Utils.Sleep(ms)
    if type(ms) ~= "number" then error("ms was not a number", 1) end
    local startTime = computer.millis()
    local endTime = startTime + ms
    while startTime <= endTime do startTime = computer.millis() end
end

function Utils.WriteToFile(path, mode, data)
    local file = filesystem.open(path, mode)
    file:write(data)
    file:close()
end

function Utils.ReadFile(path)
    local file = filesystem.open(path, "r")
    local str = ""
    while true do
        local buf = file:read(256)
        if not buf then
            break
        end
        str = str .. buf
    end
    return str
end

function Utils.ExecuteFunction(func, object, ...)
    local thread = coroutine.create(func)
    if object == nil then
        return thread, coroutine.resume(thread, ...)
    else
        return thread, coroutine.resume(thread, object, ...)
    end
end