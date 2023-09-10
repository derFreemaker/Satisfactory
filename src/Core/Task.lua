---@class Core.Task : object
---@field package func function
---@field package parent table
---@field package thread thread
---@field package closed boolean
---@field private success boolean
---@field private results any[]
---@field private noError boolean
---@field private errorObject any
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

---@param task Core.Task
local function createThread(task)
    ---@param ... any parameters
    ---@return any[] returns
    local function invokeFunc(...)
        ---@type any[]
        local result
        if task.parent then
            result = { task.func(task.parent, ...) }
        else
            result = { task.func(...) }
        end
        if coroutine.isyieldable(task.thread) then
            --? Should always return here
            return coroutine.yield(result)
        end
        --! Should never return here
        return result
    end

    task.thread = coroutine.create(invokeFunc)
    task.closed = false
end

---@private
---@param ... any args
function Task:invokeThread(...)
    self.success, self.results = coroutine.resume(self.thread, self, ...)
end

---@param ... any parameters
---@return any ... results
function Task:Execute(...)
    createThread(self)
    self:invokeThread(...)
    return table.unpack(self.results)
end

---@param args any[] parameters
---@return any[] returns
function Task:ExecuteDynamic(args)
    createThread(self)
    self:invokeThread(table.unpack(args))
    return self.results
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

---@param args any[] parameters
---@return any[] returns
function Task:ResumeDynamic(args)
    self:CheckThreadState()
    self:invokeThread(table.unpack(args))
    return self.results
end

function Task:Close()
    if self.closed then return end
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
        logger:LogError("execution error: \n" .. debug.traceback(self.thread, self.errorObject) .. debug.traceback():sub(17))
    end
end

return Utils.Class.CreateClass(Task, "Core.Task")