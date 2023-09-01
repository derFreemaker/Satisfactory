---@class Utils.Function
local Function = {}

---@param func function
---@param parent any
---@param args any[]
---@return any[] returns
function Function.DynamicInvoke(func, parent, args)
    local results
    if parent ~= nil then
        results = table.pack(func(parent, table.unpack(args)))
    else
        results = table.pack(func(table.unpack(args)))
    end
    return results
end

---@param func function
---@param parent any
---@param ... any
---@return thread thread, boolean success, any[] returns
function Function.InvokeProtected(func, parent, ...)
    local function invokeFunc(...)
        coroutine.yield(func(...))
    end
    local thread = coroutine.create(invokeFunc)
    local results
    if parent ~= nil then
        results = table.pack(coroutine.resume(thread, parent, ...))
    else
        results = table.pack(coroutine.resume(thread, ...))
    end
    coroutine.close(thread)
    local success = Utils.Table.Retrive(results, 1)
    return thread, success, results
end

---@param func function
---@param parent any
---@param args any[]
---@return thread thread, boolean success, any[] returns
function Function.DynamicInvokeProtected(func, parent, args)
    return Function.InvokeProtected(func, parent, table.unpack(args))
end

return Function