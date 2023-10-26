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
