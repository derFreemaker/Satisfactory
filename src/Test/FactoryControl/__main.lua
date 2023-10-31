local EventPullAdapter = require("Core.Event.EventPullAdapter")

local FactoryControlClient = require("FactoryControl.Client.Client")

---@class FactoryControl.Test.Main : Github_Loading.Entities.Main
---@field private m_client FactoryControl.Client
local Main = {}

function Main:Configure()
    EventPullAdapter:Initialize(self.Logger:subLogger("EventPullAdapter"))

    self.m_client = FactoryControlClient(self.Logger:subLogger("ApiClient"))
end

function Main:Run()
    log("test running")

    local controller = self.m_client:Connect("Test")

    assert(controller.IPAddress:Equals(self.m_client.NetClient:GetIPAddress()), "IP Address mismatch")

    log("test passed")
end

return Main
