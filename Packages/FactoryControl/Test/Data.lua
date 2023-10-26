---@meta
local PackageData = {}

PackageData["FactoryControlTest__main"] = {
    Location = "FactoryControl.Test.__main",
    Namespace = "FactoryControl.Test.__main",
    IsRunnable = true,
    Data = [[
local FactoryControlClient = require("FactoryControl.Client.Client")

---@class FactoryControl.Test.Main : Github_Loading.Entities.Main
---@field private m_client FactoryControl.Client
local Main = {}

function Main:Configure()
    self.m_client = FactoryControlClient(self.Logger:subLogger("ApiClient"))
end

function Main:Run()
    local controller = self.m_client:Connect("Test")

    print(controller.IPAddress)
end

return Main
]]
}

return PackageData
