local Utils = {}

---@param ms number defines how long the function will wait in Milliseconds
function Utils.Sleep(ms)
    if type(ms) ~= "number" then error("ms was not a number", 1) end
    local startTime = computer.millis()
    local endTime = startTime + ms
    while startTime <= endTime do startTime = computer.millis() end
end

---@param func function
---@param object table | nil
---@param ... any | nil
---@return thread, boolean, 'result'
function Utils.ExecuteFunction(func, object, ...)
    local thread = coroutine.create(func)
    if object == nil then
        return thread, coroutine.resume(thread, ...)
    else
        return thread, coroutine.resume(thread, object, ...)
    end
end

return Utils