---@class Core.Task : object
---@field private _Func function
---@field private _Passthrough any
---@field private _Thread thread
---@field private _Closed boolean
---@field private _Success boolean
---@field private _Results any[]
---@field private _Traceback string?
---@overload fun(func: function, passthrough: any) : Core.Task
local Task = {}

---@private
---@param func function
---@param passthrough any
function Task:__init(func, passthrough)
    self._Func = func
    self._Passthrough = passthrough
    self._Closed = false
    self._Success = true
    self._Results = {}
end

---@return boolean
function Task:IsSuccess()
    return self._Success
end

---@return any ... results
function Task:GetResults()
    return table.unpack(self._Results)
end

---@return any[] results
function Task:GetResultsArray()
    return self._Results
end

---@return string
function Task:GetTraceback()
    return self:Traceback()
end

---@private
---@param ... any args
function Task:invokeThread(...)
    self._Success, self._Results = coroutine.resume(self._Thread, ...)
end

---@param ... any parameters
---@return any ... results
function Task:Execute(...)
    ---@param ... any parameters
    ---@return any[] returns
    local function invokeFunc(...)
        ---@type any[]
        local result
        if self._Passthrough ~= nil then
            result = { self._Func(self._Passthrough, ...) }
        else
            result = { self._Func(...) }
        end
        if coroutine.isyieldable(self._Thread) then
            --? Should always return here
            return coroutine.yield(result)
        end
        --! Should never return here
        return result
    end

    self._Thread = coroutine.create(invokeFunc)
    self._Closed = false
    self._Traceback = nil

    self:invokeThread(...)
    return table.unpack(self._Results)
end

---@private
function Task:CheckThreadState()
    if self._Thread == nil then
        error("cannot resume a not started task")
    end
    if self._Closed then
        error("cannot resume a closed task")
    end
    if coroutine.status(self._Thread) == "running" then
        error("cannot resume running task")
    end
    if coroutine.status(self._Thread) == "dead" then
        error("cannot resume dead task")
    end
end

---@param ... any parameters
---@return any ... results
function Task:Resume(...)
    self:CheckThreadState()
    self:invokeThread(...)
    return table.unpack(self._Results)
end

function Task:Close()
    if self._Closed then return end
    self:Traceback()
    coroutine.close(self._Thread)
    self._Closed = true
end

---@private
---@return string traceback
function Task:Traceback()
    if self._Traceback ~= nil then
        return self._Traceback
    end
    local error = ""
    if type(self._Results) == "string" then
        error = self._Results --[[@as string]]
    end
    self._Traceback = debug.traceback(self._Thread, error)
    return self._Traceback
end

---@return "not created" | "dead" | "normal" | "running" | "suspended"
function Task:State()
    if self._Thread == nil then
        return "not created"
    end
    return coroutine.status(self._Thread);
end

---@param logger Core.Logger?
function Task:LogError(logger)
    self:Close()
    if not self._Success and logger then
        logger:LogError("Task: \n" .. self:Traceback() .. debug.traceback():sub(17))
    end
end

return Utils.Class.CreateClass(Task, "Core.Task")
