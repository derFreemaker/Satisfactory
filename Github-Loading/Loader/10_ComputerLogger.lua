---@class Computer.Logger
---@field private _LoggerHistory { [integer]: (Github_Loading.Logger | Core.Logger) }
---@field package CurrentLogger (Github_Loading.Logger | Core.Logger)?
___logger = { LoggerHistory = {}, CurrentLogger = nil }

function ___logger:initialize()
    local function wrapFunc(func)
        local function invoke(...)
            func(self, ...)
        end
        return invoke
    end

    log = wrapFunc(self.log)
    error = wrapFunc(self.error)
    assert = wrapFunc(self.assert)
    computer.panic = wrapFunc(self.panic)
end

---@param logger Github_Loading.Logger | Core.Logger
function ___logger:setLogger(logger)
    if logger == nil then
        return
    end
    table.insert(self._LoggerHistory, logger)
    self._CurrentLogger = logger
end

function ___logger:revert()
    local loggerHistoryLength = #self._LoggerHistory
    if loggerHistoryLength == 1 then
        error("Should never remove last logger")
        return
    end
    local logger = self._LoggerHistory[loggerHistoryLength]
    self._LoggerHistory[loggerHistoryLength] = nil
    if logger == nil then return end
    self._CurrentLogger = logger
end

---@param ... any
function ___logger:log(...)
    local message = ""
    for i, arg in pairs({ ... }) do
        if i == 1 then
            message = tostring(arg) or "nil"
        else
            message = message .. "   " .. (tostring(arg) or "nil")
        end
    end
    local currentLogger = self._CurrentLogger
    if currentLogger then
        pcall(currentLogger.Log, currentLogger, "[LOG]: " .. message, 10)
    end
end

local errorFunc = error
---@param message string
---@param level integer?
function ___logger:error(message, level)
    message = message or "no error message"
    level = level or 1
    level = level + 1
    local currentLogger = self._CurrentLogger
    if currentLogger then
        local debugInfo = debug.getinfo(level)
        local errorMessage = "[ERROR-LOG] " .. debugInfo.short_src .. ":" .. debugInfo.currentline .. ": " .. message
        errorMessage = debug.traceback(errorMessage, level + 1)
        pcall(currentLogger.Log, currentLogger, errorMessage, 4)
    end
    errorFunc(message, level)
end

local asserFunc = assert
---@generic T
---@param condition T
---@param message? any
---@param ... any
---@return T, any ...
function ___logger:assert(condition, message, ...)
    message = message or "assertation failed"
    if not condition then
        local currentLogger = self._CurrentLogger
        if currentLogger then
            local debugInfo = debug.getinfo(2)
            local errorMessage = "[ASSERT-LOG] " ..
                debugInfo.short_src .. ":" .. debugInfo.currentline .. ": " .. message
            errorMessage = debug.traceback(errorMessage, 3)
            pcall(currentLogger.Log, currentLogger, errorMessage, 4)
        end
    end
    return asserFunc(condition, message, ...)
end

local panicFunc = computer.panic
---@param errorMsg string
function ___logger:panic(errorMsg) ---@diagnostic disable-line
    local currentLogger = self._CurrentLogger
    if currentLogger then
        local debugInfo = debug.getinfo(2)
        local errorMessage = "[PANIC-LOG] " .. debugInfo.short_src .. ":" .. debugInfo.currentline .. ": " .. errorMsg
        errorMessage = debug.traceback(errorMessage, 3)
        pcall(currentLogger.Log, currentLogger, errorMessage, 10)
    end
    return panicFunc(errorMsg)
end
