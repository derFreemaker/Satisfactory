local TestFramework = require("Test.Framework.Framework")
local Helper = require("Test.FactoryControl.Helper")

---@param logger Core.Logger
local function connection(logger)
    local client = Helper.CreateFactoryControlClient(logger)

    log("connecting...")
    local controller = client:Connect("Connection")

    assert(controller.IPAddress:Equals(client.NetClient:GetIPAddress()), "IP Address mismatch")
end
TestFramework:AddTest("Connection", connection)
