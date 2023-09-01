local LoadedLoaderFiles = table.pack(...)[1]
---@type Utils
local Utils = LoadedLoaderFiles["/Github-Loading/Loader/Utils"][1]

---@class Github_Loading.Listener
---@field private func function
---@field private parent any
local Listener = {}

---@param func function
---@param parent any
---@return Github_Loading.Listener
function Listener.new(func, parent)
    local metatable = {
        __index = Listener
    }
    return setmetatable({
        func = func,
        parent = parent
    }, metatable)
end

---@param Task Core.Task | fun(func: function, parent: table?) : Core.Task
---@return Core.Task task
function Listener:convertToTask(Task)
    return Task(self.func, self.parent)
end

---@param logger Github_Loading.Logger?
---@param ... any
---@return boolean success, any ...
function Listener:Execute(logger, ...)
    local thread, success, results = Utils.Function.InvokeProtected(self.func, self.parent, ...)
    if not success and logger then
        logger:LogError("execution error: \n" .. debug.traceback(thread, results[1]) .. debug.traceback():sub(17))
    end
    return success, table.unpack(results)
end

---@param logger Github_Loading.Logger?
---@param args any[]
---@return boolean success, any[] results
function Listener:ExecuteDynamic(logger, args)
    local thread, success, results = Utils.Function.DynamicInvokeProtected(self.func, self.parent, args)
    if not success and logger then
        logger:LogError("execution error: \n" .. debug.traceback(thread, results[1]) .. debug.traceback():sub(17))
    end
    return success, results
end

return Listener