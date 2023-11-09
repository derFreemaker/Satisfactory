local Framework = require("Test.Framework.Framework")
local Host = require("Hosting.Host")

---@class FactoryControl.Test.Main : Github_Loading.Entities.Main
---@field private m_host Hosting.Host
---@field private m_testFramework Test.Framework
local Main = {}

function Main:Configure()
    self.m_host = Host(self.Logger:subLogger("Host"), "Host")

    self.m_testFramework = self.m_host:AddTesting()
end

function Main:Run()
    self.m_testFramework:Run(self.Logger:subLogger("TestFramework"))
end

return Main
