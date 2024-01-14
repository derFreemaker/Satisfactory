local Data={
["Test.Framework.__events"] = [[
require("Test.Framework.Extensions.HostExtensions")

]],
["Test.Framework.init"] = [[
local Task = require("Core.Common.Task")

local Test = require("Test.Framework.Wrapper")

---@class Test.Framework : object
---@field m_tests Test[]
---@overload fun() : Test.Framework
local Framework = {}

---@private
function Framework:__init()
    self.m_tests = {}
end

---@param name string
---@param func fun(logger: Core.Logger, netClient: Net.Core.NetworkClient)
function Framework:AddTest(name, func)
    table.insert(self.m_tests, Test(name, Task(func)))
end

---@param logger Core.Logger
function Framework:Run(logger)
    logger:LogInfo("Running tests...")

    local successful = 0
    local failed = 0
    for _, test in ipairs(self.m_tests) do
        test:Run(logger)
        if test:WasSuccessful() then
            successful = successful + 1
        else
            failed = failed + 1
        end
    end

    logger:LogInfo(
        "Tests finished with "
        .. successful .. " successful tests and "
        .. failed .. " failed tests"
    )
end

return Utils.Class.Create(Framework, "Test.Framework")()

]],
["Test.Framework.Wrapper"] = [[
local Task = require("Core.Common.Task")
local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@class Test : object
---@field m_name string
---@field m_task Core.Task
---@overload fun(name: string, task: Core.Task) : Test
local Wrapper = {}

---@private
---@param name string
---@param task Core.Task
function Wrapper:__init(name, task)
    self.m_name = name
    self.m_task = task
end

---@param logger Core.Logger
function Wrapper:Run(logger)
    logger:LogInfo("Test: \"" .. self.m_name .. "\" running...")

    local testLogger = require("Core.Common.Logger")("TestFramework", 1)
    testLogger.OnLog:AddTask(
        Task(function(message)
            Utils.File.Write("/Logs/Tests/" .. self.m_name .. ".log", "a", message .. "\n", true)
        end)
    )
    testLogger.OnClear:AddTask(
        Task(function()
            Utils.File.Write("/Logs/Tests/" .. self.m_name .. ".log", "w", "", true)
        end)
    )
    testLogger:Clear()
    ___logger:setLogger(testLogger)

    EventPullAdapter:Initialize(testLogger:subLogger("EventPullAdapter"))

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
function Wrapper:WasSuccessful()
    return self.m_task:IsSuccess()
end

return Utils.Class.Create(Wrapper, "Test.Framework.Wrapper")

]],
["Test.Framework.Extensions.HostExtensions"] = [[
---@class Hosting.Host
local HostExtensions = {}

---@return Test.Framework testFramework
function HostExtensions:AddTesting()
    local testFramework = require("Test.Framework.init")
    for _, module in pairs(PackageLoader.CurrentPackage.Modules) do
        require(module.Namespace)
    end
    return testFramework
end

Utils.Class.Extend(require("Hosting.Host"), HostExtensions)

]],
}

return Data
