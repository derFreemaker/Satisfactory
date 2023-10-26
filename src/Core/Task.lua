---@class Core.Task : object
---@field private m_func function
---@field private m_passthrough any
---@field private m_thread thread
---@field private m_closed boolean
---@field private m_success boolean
---@field private m_results any[]
---@field private m_error string?
---@field private m_traceback string?
---@overload fun(func: function, passthrough: any) : Core.Task
local Task = {}

---@private
---@param func function
---@param passthrough any
function Task:__init(func, passthrough)
    self.m_func = func
    self.m_passthrough = passthrough
    self.m_closed = false
    self.m_success = true
    self.m_results = {}
end

---@return boolean
function Task:IsSuccess()
    return self.m_success
end

---@return any ... results
function Task:GetResults()
    return table.unpack(self.m_results)
end

---@return any[] results
function Task:GetResultsArray()
    return self.m_results
end

---@return string
function Task:GetTraceback()
    return self:Traceback()
end

---@private
---@param ... any args
function Task:invokeThread(...)
    self.m_success, self.m_error = coroutine.resume(self.m_thread, ...)
end

---@param ... any parameters
---@return any ... results
function Task:Execute(...)
    ---@param ... any parameters
    local function invokeFunc(...)
        if self.m_passthrough ~= nil then
            self.m_results = { self.m_func(self.m_passthrough, ...) }
        else
            self.m_results = { self.m_func(...) }
        end
    end

    self.m_thread = coroutine.create(invokeFunc)
    self.m_closed = false
    self.m_traceback = nil

    self:invokeThread(...)
    return table.unpack(self.m_results)
end

---@private
function Task:CheckThreadState()
    local state = self:State()

    if state == "not created" then
        error("cannot resume a not started task")
    end

    if self.m_closed then
        error("cannot resume a closed task")
    end

    if state == "running" then
        error("cannot resume running task")
    end

    if state == "dead" then
        error("cannot resume dead task")
    end
end

---@param ... any parameters
---@return any ... results
function Task:Resume(...)
    self:CheckThreadState()
    self:invokeThread(...)
    return table.unpack(self.m_results)
end

function Task:Close()
    if self.m_closed then return end
    if not self.m_success then
        self:Traceback()
    end
    coroutine.close(self.m_thread)
    self.m_closed = true
end

---@private
---@return string traceback
function Task:Traceback()
    if self.m_traceback ~= nil or self.m_closed then
        return self.m_traceback
    end
    self.m_traceback = debug.traceback(self.m_thread, self.m_error or "")
        .. "\n[THREAD START]\n" .. debug.traceback():sub(18)
    return self.m_traceback
end

---@return "not created" | "dead" | "normal" | "running" | "suspended"
function Task:State()
    if self.m_thread == nil then
        return "not created"
    end
    return coroutine.status(self.m_thread);
end

---@param logger Core.Logger?
function Task:LogError(logger)
    self:Close()
    if not self.m_success and logger then
        logger:LogError("Task [Error]:\n" .. self:Traceback())
    end
end

return Utils.Class.CreateClass(Task, "Core.Task")
