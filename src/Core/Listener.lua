---@class Core.Listener : Object
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

---@param ... any
---@return boolean success, any ...
function Listener:Execute(...)
    local success, result = Utils.Function.InvokeProtected(self.func, self.parent, ...)
    assert(success, "listener execution failed: \n" .. debug.traceback(result[1]))
    return success, table.unpack(result)
end

---@param args any[]
---@return boolean success, any[] results
function Listener:ExecuteDynamic(args)
    local success, results = Utils.Function.DynamicInvokeProtected(self.func, self.parent, args)
    assert(success, "listener dynamic execution failed: \n" .. debug.traceback(results[1]))
    return success, results
end

return Utils.Class.CreateClass(Listener, "Listener")