---@class Core.Task : object
---@field package func function
---@field package parent table
---@field package thread thread
---@field package closed boolean
---@field private success boolean
---@field private results any[]
---@field private noError boolean
---@field private errorObject any
---@field private traceback string
---@overload fun(func: function, parent: table?) : Core.Task
local Task = {}

---@private
---@param func function
---@param parent table
function Task:__init(func, parent)
    self.func = func
    self.parent = parent
    self.closed = false
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

---@return any errorObject
function Task:GetErrorObject()
    return self.errorObject
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
        if self.parent ~= nil then
            result = { self.func(self.parent, ...) }
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
    if not self.success then
        self.traceback = debug.traceback(self.thread, self.results[1])
    end
    self.noError, self.errorObject = coroutine.close(self.thread)
    self.closed = true
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
    if not self.noError and logger then
        logger:LogError("Task: \n" .. self.traceback .. debug.traceback():sub(17))
    end
end

return Utils.Class.CreateClass(Task, "Core.Task")