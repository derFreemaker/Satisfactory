local Utils = require("src (Outdated).Core.shared.Utils.Index")

---@class Listener
---@field private func function
---@field private parent any
local Listener = {}
Listener.__index = Listener

---@param func function
---@param parent any
---@return Listener
function Listener.new(func, parent)
    return setmetatable({
        func = func,
        parent = parent
    }, Listener)
end

---@param logger Core.Logger
---@param ... any
---@return thread, boolean, 'result'
function Listener:Execute(logger, ...)
    local thread, status, result = Utils.ExecuteFunction(self.func, self.parent, ...)
    if not status then
        logger:LogError("execution error: \n" .. debug.traceback(thread, result) .. debug.traceback():sub(17))
    end
    return thread, status, result
end

return Listener