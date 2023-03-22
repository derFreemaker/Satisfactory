local Listener = {}
Listener.__index = Listener

function Listener.new(func, object)
    return setmetatable({
        Func = func,
        Object = object
    }, Listener)
end

function Listener:Execute(logger, ...)
    local thread, status, result = Utils.ExecuteFunction(self.Func, self.Object, ...)
    if not status then
        logger:LogError("execution error: \n" .. debug.traceback(thread, result) .. debug.traceback():sub(17))
    end
    return thread, status, result
end

return Listener