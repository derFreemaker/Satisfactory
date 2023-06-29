local Tools = require("Ficsit-Networks_Sim.Utils.Tools")

---@class Ficsit_Networks_Sim.Utils.Listener
---@field private func function
---@field private parent any
local Listener = {}
Listener.__index = Listener

---@param func function
---@param parent any
---@return Ficsit_Networks_Sim.Utils.Listener
function Listener.new(func, parent)
    return setmetatable({
        func = func,
        parent = parent
    }, Listener)
end

---@param logger Ficsit_Networks_Sim.Utils.Logger | nil
---@param ... any
---@return thread, boolean, 'result'
function Listener:Execute(logger, ...)
    local thread, status, result = Tools.ExecuteFunctionAsThread(self.func, self.parent, ...)
    if not status then
        local errorMessage = "execution error: \n" .. debug.traceback(thread, result)
            .. debug.traceback():sub(17)
        if logger == nil then
            error(errorMessage)
        end
        logger:LogError(errorMessage)
    end
    return thread, status, result
end

return Listener