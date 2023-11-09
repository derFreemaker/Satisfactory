---@class Test.Framework.Test : object
---@field m_name string
---@field m_task Core.Task
---@overload fun(name: string, task: Core.Task) : Test.Framework.Test
local Test = {}

---@private
---@param name string
---@param task Core.Task
function Test:__init(name, task)
    self.m_name = name
    self.m_task = task
end

---@param logger Core.Logger
function Test:Run(logger)
    logger:LogInfo("Test: \"" .. self.m_name .. "\" running...")

    local testLogger = require("Core.Common.Logger")("TestFramework", 1)
    testLogger.OnLog:AddListener(function(message)
        Utils.File.Write("/Logs/Tests/" .. self.m_name .. ".log", "a", message .. "\n", true)
    end)
    testLogger.OnClear:AddListener(function()
        Utils.File.Write("/Logs/Tests/" .. self.m_name .. ".log", "w", "", true)
    end)
    testLogger:Clear()
    ___logger:setLogger(testLogger)

    self.m_task:Execute(testLogger)
    self.m_task:Close()
    ___logger:revert()

    if self.m_task:IsSuccess() then
        local message = "Test: \"" .. self.m_name .. "\" passed"
        logger:LogInfo(message)
        testLogger:LogInfo(message)
    else
        local message = "Test: \"" .. self.m_name .. "\" failed with error:"
        local traceback = self.m_task:GetTraceback()
        logger:LogError(message, traceback)
        testLogger:LogError(message, traceback)
    end
end

---@return boolean
function Test:WasSuccessfull()
    return self.m_task:IsSuccess()
end

return Utils.Class.CreateClass(Test, "Test.Framework.Test")
