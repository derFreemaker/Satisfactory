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

return Listener