---@class Computer.Logger
---@field package m_loggerHistory { [integer]: (Github_Loading.Logger | Core.Logger) }
---@field package m_currentLogger (Github_Loading.Logger | Core.Logger)?
___logger = { m_loggerHistory = {} }

function ___logger:initialize()
    ---@diagnostic disable-next-line
    log = function(...)
        self:log(...)
    end

    ---@diagnostic disable-next-line
    computer.panic = function(errorMsg)
        self:panic(errorMsg)
    end
end

---@param logger Github_Loading.Logger | Core.Logger
function ___logger:setLogger(logger)
    if logger == nil then
        return
    end
    table.insert(self.m_loggerHistory, logger)
    self.m_currentLogger = logger
end

function ___logger:revert()
    local loggerHistoryLength = #self.m_loggerHistory
    if loggerHistoryLength == 1 then
        error("Should never remove last logger")
        return
    end
    local logger = self.m_loggerHistory[loggerHistoryLength]
    self.m_loggerHistory[loggerHistoryLength] = nil
    if logger == nil then return end
    self.m_currentLogger = logger
end

---@param ... any
function ___logger:log(...)
    local debugInfo = debug.getinfo(3)
    local callerMsg = ({ computer.magicTime() })[2] .. " [Log] -> "
        .. debugInfo.source .. ":" .. debugInfo.currentline .. ":"

    local currentLogger = self.m_currentLogger
    if currentLogger then
        pcall(currentLogger.LogWrite, currentLogger, callerMsg, ...)
    end
end

local panicFunc = computer.panic
---@param errorMsg string
function ___logger:panic(errorMsg) ---@diagnostic disable-line
    local currentLogger = self.m_currentLogger
    if currentLogger then
        local debugInfo = debug.getinfo(3)
        local errorMessage = "[PANIC-LOG] " .. debugInfo.short_src .. ":" .. debugInfo.currentline .. ": " .. errorMsg
        errorMessage = debug.traceback(errorMessage, 3)
        pcall(currentLogger.LogFatal, currentLogger, errorMessage)
    end
    return panicFunc(errorMsg)
end
