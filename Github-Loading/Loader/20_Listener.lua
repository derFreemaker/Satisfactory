local LoadedLoaderFiles = table.pack(...)[1]
---@type Utils
local Utils = LoadedLoaderFiles["/Github-Loading/Loader/10_Utils.lua"][1]

---@class Github_Loading.Listener
---@field private func function
---@field private parent any
local Listener = {}

---@param func function
---@param parent any
---@return Github_Loading.Listener
function Listener.new(func, parent)
    local metatable = Listener
    metatable.__index = Listener
    return setmetatable({
        func = func,
        parent = parent
    }, metatable)
end

---@param ... any
---@return thread thread, boolean success, table results
function Listener:Execute(...)
    local thread, status, result = Utils.Function.InvokeFunctionAsThread(self.func, self.parent, ...)
    if not status then
        error("execution failed: \n" .. debug.traceback(thread, result[1]))
    end
    return thread, status, result
end

---@param args table
---@return thread thread, boolean success, table results
function Listener:ExecuteDynamic(args)
    local thread, status, result = Utils.Function.InvokeDynamicAsThread(self.func, self.parent, args)
    if not status then
        error("execution failed: \n" .. debug.traceback(thread, result[1]))
    end
    return thread, status, result
end

return Listener