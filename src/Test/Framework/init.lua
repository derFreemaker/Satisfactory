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
        "finished with "
        .. successful .. " successful test(s) and "
        .. failed .. " failed test(s)"
    )
end

return class("Test.Framework", Framework)()
