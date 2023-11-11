---@meta
local PackageData = {}

PackageData["TestCore__main"] = {
    Location = "Test.Core.__main",
    Namespace = "Test.Core.__main",
    IsRunnable = true,
    Data = [[
---@using Test.Framework

local Host = require("Hosting.Host")

---@class Test.Core.Main : Github_Loading.Entities.Main
---@field private m_host Hosting.Host
---@field private m_testFramework Test.Framework
local Main = {}

function Main:Configure()
    log("called configure")

    self.m_host = Host(self.Logger:subLogger("Host"), "Host")

    self.m_testFramework = self.m_host:AddTesting()
end

function Main:Run()
    log("called run")

    self.m_testFramework:Run(self.Logger:subLogger("TestFramework"))
end

return Main
]]
}

return PackageData
