---@class Computer.Logger
---@field private _LoggerHistory { [integer]: (Github_Loading.Logger | Core.Logger) }
---@field package CurrentLogger (Github_Loading.Logger | Core.Logger)?
___logger = { _LoggerHistory = {}, CurrentLogger = nil }

function ___logger:initialize()
    local function wrapFunc(func)
        local function invoke(...)
            func(self, ...)
        end
        return invoke
    end

    log = wrapFunc(self.log)
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
    local currentLogger = self._CurrentLogger
    if currentLogger then
        pcall(currentLogger.LogWrite, currentLogger, ...)
    end
end

local panicFunc = computer.panic
---@param errorMsg string
function ___logger:panic(errorMsg) ---@diagnostic disable-line
    local currentLogger = self._CurrentLogger
    if currentLogger then
        local debugInfo = debug.getinfo(2)
        local errorMessage = "[PANIC-LOG] " .. debugInfo.short_src .. ":" .. debugInfo.currentline .. ": " .. errorMsg
        errorMessage = debug.traceback(errorMessage, 3)
        pcall(currentLogger.LogFatal, currentLogger, errorMessage)
    end
    return panicFunc(errorMsg)
end
