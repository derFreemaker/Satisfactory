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
    require("Test.FactoryControl.Tests.Tests")(self.m_client)
end

return Main
