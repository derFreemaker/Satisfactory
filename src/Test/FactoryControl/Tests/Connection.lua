---@param client FactoryControl.Client
---@return FactoryControl.Client.Entities.Controller
local function test(client)
    -- Test: connecting

    local controller = client:Connect("Test")

    assert(controller.IPAddress:Equals(client.NetClient:GetIPAddress()), "IP Address mismatch")

    log("passed test: connecting")

    return controller
end
return test
