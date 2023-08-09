local Utils = require("Github_Loading.shared.Utils")

---@class Github_Loading.shared.Listener
---@field private func function
---@field private parent any
local Listener = {}
Listener.__index = Listener

---@param func function
---@param parent any
---@return Github_Loading.shared.Listener
function Listener.new(func, parent)
    return setmetatable({
        func = func,
        parent = parent
    }, Listener)
end

---@param ... any
---@return thread, boolean, 'result'
function Listener:Execute(...)
    local thread, status, result = Utils.ExecuteFunctionAsThread(self.func, self.parent, ...)
    if not status then
        error("execution error: \n" .. debug.traceback(thread, result) .. debug.traceback():sub(17))
    end
    return thread, status, result
end

return Listener