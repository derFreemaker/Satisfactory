local LoadedLoaderFiles = ({ ... })[1]
---@type Utils
local Utils = LoadedLoaderFiles["/Github-Loading/Loader/Utils"][1]

---@class Github_Loading.Listener
---@field private _Func function
---@field private _Parent any
local Listener = {}

---@param func function
---@param parent any
---@return Github_Loading.Listener
function Listener.new(func, parent)
    return setmetatable({
        _Func = func,
        _Parent = parent
    }, { __index = Listener })
end

---@param Task Core.Task | fun(func: function, parent: table?) : Core.Task
---@return Core.Task task
function Listener:convertToTask(Task)
    return Task(self._Func, self._Parent)
end

---@param logger Github_Loading.Logger?
---@param ... any
---@return boolean success, any ...
function Listener:Execute(logger, ...)
    local success, results
    if self._Parent ~= nil then
        _, success, results = Utils.Function.InvokeProtected(self._Func, self._Parent, ...)
    else
        _, success, results = Utils.Function.InvokeProtected(self._Func, ...)
    end
    return success, table.unpack(results)
end

return Listener
