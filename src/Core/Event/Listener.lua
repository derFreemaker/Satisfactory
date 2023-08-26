---@class Core.Listener : object
---@field private func function
---@field private parent any
---@overload fun(func: function, parent: any) : Core.Listener
local Listener = {}

---@private
---@param func function
---@param parent any
function Listener:Listener(func, parent)
    self.func = func
    self.parent = parent
end

---@param logger Core.Logger?
---@param ... any
---@return boolean success, any result, any ...
function Listener:Execute(logger, ...)
    local thread, success, results = Utils.Function.InvokeProtected(self.func, self.parent, ...)
    if not success and logger then
        logger:LogError("execution error: \n" .. debug.traceback(thread, results[1]) .. debug.traceback():sub(17))
    end
    return success, table.unpack(results)
end

---@param logger Core.Logger?
---@param args any[]
---@return boolean success, any[] results
function Listener:ExecuteDynamic(logger, args)
    local thread, success, results = Utils.Function.DynamicInvokeProtected(self.func, self.parent, args)
    if not success and logger then
        logger:LogError("execution error: \n" .. debug.traceback(thread, results[1]) .. debug.traceback():sub(17))
    end
    return success, results
end

return Utils.Class.CreateClass(Listener, "Listener")