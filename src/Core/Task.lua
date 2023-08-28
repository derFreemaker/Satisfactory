---@class Core.Task : object
---@field private func function
---@field private parent table
---@field private thread thread
---@field private success boolean
---@field private closed boolean
---@field private results any[]
---@field private noError boolean
---@field private errorObject any
---@overload fun(func: function, parent: table?) : Core.Task
local Task = {}

---@private
---@param ... any parameters
---@return any ... returns
function Task:invokeFunc(...)
    if self.parent then
        return coroutine.yield(self.func(self.parent, ...))
    end
    return coroutine.yield(self.func(...))
end

---@private
---@param func function
---@param parent table
function Task:Task(func, parent)
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

---@param success boolean
---@param ... any
---@return boolean success, table returns
local function extractData(success, ...)
    return success, { ... }
end

---@param ... any parameters
---@return any ... results
function Task:Execute(...)
    self.thread = coroutine.create(self.invokeFunc)
    self.success, self.results = extractData(coroutine.resume(self.thread, self, ...))
    return table.unpack(self.results)
end

---@param args any[] parameters
---@return any[] returns
function Task:ExecuteDynamic(args)
    self.thread = coroutine.create(self.invokeFunc)
    self.success, self.results = extractData(coroutine.resume(self.thread, self, table.unpack(args)))
    return self.results
end

function Task:Close()
    self.noError, self.errorObject = coroutine.close(self.thread)
    self.closed = true
end

---@param logger Core.Logger?
function Task:LogError(logger)
    if not self.closed then
        self:Close()
    end
    if not self.noError and logger then
        logger:LogError("execution error: \n" .. debug.traceback(self.thread, self.errorObject) .. debug.traceback():sub(17))
    end
end

return Utils.Class.CreateClass(Task, "Task")