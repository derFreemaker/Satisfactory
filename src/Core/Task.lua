---@class Core.Task : object
---@field package func function
---@field package passthrough table
---@field package thread thread
---@field package closed boolean
---@field private success boolean
---@field private results any[]
---@field private traceback string?
---@overload fun(func: function, passthrough: table?) : Core.Task
local Task = {}

---@private
---@param func function
---@param passthrough table
function Task:__init(func, passthrough)
    self.func = func
    self.passthrough = passthrough
    self.closed = false
    self.success = true
    self.results = {}
end

---@return boolean
function Task:IsSuccess()
    return self.success
end

---@return any ... results
function Task:GetResults()
    return table.unpack(self.results)
end

---@return any[] results
function Task:GetResultsArray()
    return self.results
end

---@return string
function Task:GetTraceback()
    if self.traceback == nil then
        return self:Traceback()
    end
    return self.traceback
end

---@private
---@param ... any args
function Task:invokeThread(...)
    self.success, self.results = coroutine.resume(self.thread, ...)
end

---@param ... any parameters
---@return any ... results
function Task:Execute(...)
    ---@param ... any parameters
    ---@return any[] returns
    local function invokeFunc(...)
        ---@type any[]
        local result
        if self.passthrough ~= nil then
            result = { self.func(self.passthrough, ...) }
        else
            result = { self.func(...) }
        end
        if coroutine.isyieldable(self.thread) then
            --? Should always return here
            return coroutine.yield(result)
        end
        --! Should never return here
        return result
    end

    self.thread = coroutine.create(invokeFunc)
    self.closed = false
    self.traceback = nil

    self:invokeThread(...)
    return table.unpack(self.results)
end

---@private
function Task:CheckThreadState()
    if self.thread == nil then
        error("cannot resume a not started task")
    end
    if self.closed then
        error("cannot resume a closed task")
    end
    if coroutine.status(self.thread) == "running" then
        error("cannot resume running task")
    end
    if coroutine.status(self.thread) == "dead" then
        error("cannot resume dead task")
    end
end

---@param ... any parameters
---@return any ... results
function Task:Resume(...)
    self:CheckThreadState()
    self:invokeThread(...)
    return table.unpack(self.results)
end

function Task:Close()
    if self.closed then return end
    self:Traceback()
    coroutine.close(self.thread)
    self.closed = true
end

---@return string traceback
function Task:Traceback()
    if self.traceback ~= nil then
        return self.traceback end
    local error = ""
    if type(self.results) == "string" then
        error = self.results --[[@as string]]
    end
    self.traceback = debug.traceback(self.thread, error)
    return self.traceback
end

---@return "not created" | "dead" | "normal" | "running" | "suspended"
function Task:State()
    if self.thread == nil then
        return "not created"
    end
    return coroutine.status(self.thread);
end

---@param logger Core.Logger?
function Task:LogError(logger)
    self:Close()
    if not self.success and logger then
        logger:LogError("Task: \n" .. self:Traceback() .. debug.traceback():sub(17))
    end
end

return Utils.Class.CreateClass(Task, "Core.Task")