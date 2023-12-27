---@class Core.Task : object
---@field private m_func function
---@field private m_passthrough any[]
---@field private m_thread thread
---@field private m_closed boolean
---@field private m_success boolean
---@field private m_results any[]
---@field private m_error string?
---@field private m_traceback string?
---@overload fun(func: function, ...: any) : Core.Task
local Task = {}

---@private
---@param func function
---@param ... any
function Task:__init(func, ...)
    self.m_func = func

    local passthrough = { ... }
    local count = #passthrough
    if count > 16 then
        -- look into Execute function for more information
        error("cannot pass more than 16 arguments")
    end
    if count > 0 then
        self.m_passthrough = passthrough
    end

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

---@param length integer
---@return fun(func: function, tbl: table, ...: any) : ... : any
local function createInvokeFunc(length)
    local funcStart = "return function(func, tbl, ...)\n    return func(\n"
    local parameter = "        tbl[%d],\n"
    local funcEnd = "        ...)\nend"

    local newFunc = funcStart

    for i = 1, length, 1 do
        newFunc = newFunc .. string.format(parameter, i)
    end

    newFunc = newFunc .. funcEnd

    ---@type (fun() : (fun(func: function, tbl: table, ...: any) : ... : any))?
    local createFunc = load(newFunc)
    if not createFunc then
        error("unable to create func")
    end

    return createFunc()
end

---@param ... any parameters
---@return any ... results
function Task:Execute(...)
    ---@param ... any parameters
    local function invokeFunc(func, passthrough, ...)
        if passthrough ~= nil then
            -- //TODO
            -- Having to do this is a bit annoying, but it's the only way to get the correct number of arguments
            -- example code that doesn't work for some reason:
            --
            -- local args1 = { "hi1", "hi2" }
            -- local args2 = { "hi3", "hi4" }
            -- local function foo(...)
            --     print(...)
            -- end
            -- foo(table.unpack(args1), table.unpack(args2))
            --
            -- Output:
            -- hi1 hi3 hi4

            local invoke = createInvokeFunc(#passthrough)
            return { invoke(func, passthrough, ...) }
        else
            return { self.m_func(...) }
        end
    end

    self.m_thread = coroutine.create(invokeFunc)
    self.m_closed = false
    self.m_traceback = nil

    local success, results = coroutine.resume(self.m_thread, self.m_func, self.m_passthrough, ...)
    self.m_success = success
    if success then
        self.m_results = results
    else
        self.m_error = results
    end

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
    self.m_success, self.m_error = coroutine.resume(self.m_thread, ...)
    return table.unpack(self.m_results)
end

function Task:Close()
    if self.m_closed then return end
    if not self.m_success then
        self:Traceback(false)
    end
    coroutine.close(self.m_thread)
    self.m_closed = true
end

---@private
---@param all boolean?
---@return string traceback
function Task:Traceback(all)
    if self.m_traceback ~= nil or self.m_closed then
        return self.m_traceback
    end
    self.m_traceback = debug.traceback(self.m_thread, self.m_error or "") .. "\n[THREAD START]"
    if all then
        self.m_traceback = self.m_traceback .. "\n" .. debug.traceback():sub(18)
    end
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
---@param all boolean?
function Task:LogError(logger, all)
    self:Close()
    if not self.m_success and logger then
        logger:LogError("Task [Error]:\n" .. self:Traceback(all))
    end
end

return Utils.Class.Create(Task, "Core.Common.Task")
