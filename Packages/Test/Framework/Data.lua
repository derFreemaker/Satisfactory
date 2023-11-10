---@meta
local PackageData = {}

PackageData["TestFramework__events"] = {
    Location = "Test.Framework.__events",
    Namespace = "Test.Framework.__events",
    IsRunnable = true,
    Data = [[
require("Test.Framework.Extensions.HostExtensions")
]]
}

PackageData["TestFrameworkFramework"] = {
    Location = "Test.Framework.Framework",
    Namespace = "Test.Framework.Framework",
    IsRunnable = true,
    Data = [[
local Task = require("Core.Common.Task")

local Test = require("Test.Framework.Wrapper")

---@class Test.Framework : object
---@field m_tests Test.Framework.Wrapper[]
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

    local successfull = 0
    local failed = 0
    for _, test in ipairs(self.m_tests) do
        test:Run(logger)
        if test:WasSuccessfull() then
            successfull = successfull + 1
        else
            failed = failed + 1
        end
    end

    logger:LogInfo(
        "Tests finished with "
        .. successfull .. " successfull tests and "
        .. failed .. " failed tests"
    )
end

return Utils.Class.CreateClass(Framework, "Test.Framework")()
]]
}

PackageData["TestFrameworkWrapper"] = {
    Location = "Test.Framework.Wrapper",
    Namespace = "Test.Framework.Wrapper",
    IsRunnable = true,
    Data = [[
---@class Test.Framework.Wrapper : object
---@field m_name string
---@field m_task Core.Task
---@overload fun(name: string, task: Core.Task) : Test.Framework.Wrapper
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
function Wrapper:WasSuccessfull()
    return self.m_task:IsSuccess()
end

return Utils.Class.CreateClass(Wrapper, "Test.Framework.Wrapper")
]]
}

PackageData["TestFrameworkExtensionsHostExtensions"] = {
    Location = "Test.Framework.Extensions.HostExtensions",
    Namespace = "Test.Framework.Extensions.HostExtensions",
    IsRunnable = true,
    Data = [[
---@class Hosting.Host
local HostExtensions = {}

---@return Test.Framework testFramework
function HostExtensions:AddTesting()
    local testFramework = require("Test.Framework.Framework")
    for _, module in pairs(PackageLoader.CurrentPackage.Modules) do
        module:Load()
    end
    return testFramework
end

Utils.Class.ExtendClass(HostExtensions, require("Hosting.Host"))
]]
}

return PackageData
