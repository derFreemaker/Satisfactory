local LoadedLoaderFiles = ({ ... })[1]
---@type Utils
local Utils = LoadedLoaderFiles["/Github-Loading/Loader/Utils"][1]

---@class Github_Loading.Listener
---@field private m_func function
local Listener = {}

---@param func function
---@return Github_Loading.Listener
function Listener.new(func)
    return setmetatable({
        m_func = func
    }, { __index = Listener })
end

---@param Task Core.Task | fun(func: function) : Core.Task
---@return Core.Task task
function Listener:convertToTask(Task)
    return Task(self.m_func)
end

---@param logger Github_Loading.Logger?
---@param ... any
---@return boolean success, any ...
function Listener:Execute(logger, ...)
    local success, errorMsg, results = Utils.Function.InvokeProtected(self.m_func, ...)

    if not success and logger then
        logger:LogError(errorMsg)
    end
    return success, table.unpack(results)
end

return Listener
