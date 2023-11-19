local LoadedLoaderFiles = ({ ... })[1]
---@type Utils
local Utils = LoadedLoaderFiles["/Github-Loading/Loader/Utils"][1]

---@class Github_Loading.Listener
---@field private m_func function
---@field private m_parent any
local Listener = {}

---@param func function
---@param parent any
---@return Github_Loading.Listener
function Listener.new(func, parent)
    return setmetatable({
        m_func = func,
        m_parent = parent
    }, { __index = Listener })
end

---@param Task Core.Task | fun(func: function, parent: table?) : Core.Task
---@return Core.Task task
function Listener:convertToTask(Task)
    return Task(self.m_func, self.m_parent)
end

---@param logger Github_Loading.Logger?
---@param ... any
---@return boolean success, any ...
function Listener:Execute(logger, ...)
    local success, results, errorMsg
    if self.m_parent ~= nil then
        success, errorMsg, results = Utils.Function.InvokeProtected(self.m_func, self.m_parent, ...)
    else
        success, errorMsg, results = Utils.Function.InvokeProtected(self.m_func, ...)
    end

    if not success and logger then
        logger:LogError(errorMsg)
    end
    return success, table.unpack(results)
end

return Listener
