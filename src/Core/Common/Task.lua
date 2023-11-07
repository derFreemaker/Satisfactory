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

---@param ... any parameters
---@return any ... results
function Task:Execute(...)
    ---@param ... any parameters
    local function invokeFunc(...)
        if self.m_passthrough ~= nil then
            -- //TODO: this has to change
            -- Having to do this is a bit annoying, but it's the only way to get the correct number of arguments
            -- example code that doesn't work for some reason:
            --
            -- local args = { "hi1", "hi2" }
            -- local args2 = { "hi3", "hi4" }
            -- function foo2(...)
            --     print(...)
            -- end
            -- foo2(table.unpack(args, 1, #args), table.unpack(args2, 1, #args2))
            --
            -- Output:
            -- hi1 hi3 hi4
            local count = #self.m_passthrough
            if count < 5 then
                if count == 1 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            ...
                        )
                    }
                elseif count == 2 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            ...
                        )
                    }
                elseif count == 3 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            ...
                        )
                    }
                elseif count == 4 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            ...
                        )
                    }
                end
            elseif count < 9 then
                if count == 5 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            ...
                        )
                    }
                elseif count == 6 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            ...
                        )
                    }
                elseif count == 7 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            ...
                        )
                    }
                elseif count == 8 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            ...
                        )
                    }
                end
            elseif count < 13 then
                if count == 9 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            ...
                        )
                    }
                elseif count == 10 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            self.m_passthrough[10],
                            ...
                        )
                    }
                elseif count == 11 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            self.m_passthrough[10],
                            self.m_passthrough[11],
                            ...
                        )
                    }
                elseif count == 12 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            self.m_passthrough[10],
                            self.m_passthrough[11],
                            self.m_passthrough[12],
                            ...
                        )
                    }
                end
            else
                if count == 13 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            self.m_passthrough[10],
                            self.m_passthrough[11],
                            self.m_passthrough[12],
                            self.m_passthrough[13],
                            ...
                        )
                    }
                elseif count == 14 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            self.m_passthrough[10],
                            self.m_passthrough[11],
                            self.m_passthrough[12],
                            self.m_passthrough[13],
                            self.m_passthrough[14],
                            ...
                        )
                    }
                elseif count == 15 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            self.m_passthrough[10],
                            self.m_passthrough[11],
                            self.m_passthrough[12],
                            self.m_passthrough[13],
                            self.m_passthrough[14],
                            self.m_passthrough[15],
                            ...
                        )
                    }
                elseif count == 16 then
                    self.m_results = {
                        self.m_func(
                            self.m_passthrough[1],
                            self.m_passthrough[2],
                            self.m_passthrough[3],
                            self.m_passthrough[4],
                            self.m_passthrough[5],
                            self.m_passthrough[6],
                            self.m_passthrough[7],
                            self.m_passthrough[8],
                            self.m_passthrough[9],
                            self.m_passthrough[10],
                            self.m_passthrough[11],
                            self.m_passthrough[12],
                            self.m_passthrough[13],
                            self.m_passthrough[14],
                            self.m_passthrough[15],
                            self.m_passthrough[16],
                            ...
                        )
                    }
                end
            end
        else
            self.m_results = { self.m_func(...) }
        end
    end

    self.m_thread = coroutine.create(invokeFunc)
    self.m_closed = false
    self.m_traceback = nil

    self.m_success, self.m_error = coroutine.resume(self.m_thread, ...)
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
