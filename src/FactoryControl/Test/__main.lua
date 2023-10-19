local FactoryControlClient = require("FactoryControl.Client.Client")

---@class FactoryControl.Test.Main : Github_Loading.Entities.Main
---@field private _Client FactoryControl.Client
local Main = {}

function Main:Configure()
    self._Client = FactoryControlClient(self.Logger:subLogger("ApiClient"))
end

function Main:Run()
    local controller = self._Client:Connect("Test")

    print(controller.IPAddress)
end

return Main
