---@meta
local PackageData = {}

PackageData["TestFactoryControl__main"] = {
    Location = "Test.FactoryControl.__main",
    Namespace = "Test.FactoryControl.__main",
    IsRunnable = true,
    Data = [[
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
]]
}

PackageData["TestFactoryControlTestsConnection"] = {
    Location = "Test.FactoryControl.Tests.Connection",
    Namespace = "Test.FactoryControl.Tests.Connection",
    IsRunnable = true,
    Data = [[
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
]]
}

PackageData["TestFactoryControlTestsTests"] = {
    Location = "Test.FactoryControl.Tests.Tests",
    Namespace = "Test.FactoryControl.Tests.Tests",
    IsRunnable = true,
    Data = [[
---@param client FactoryControl.Client
local function test(client)
    log("tests running")

    local controller = require("Test.FactoryControl.Tests.Connection")(client)

    require("Test.FactoryControl.Tests.Features.Button")(controller)
    require("Test.FactoryControl.Tests.Features.Switch")(controller)
end
return test
]]
}

PackageData["TestFactoryControlTestsFeaturesButton"] = {
    Location = "Test.FactoryControl.Tests.Features.Button",
    Namespace = "Test.FactoryControl.Tests.Features.Button",
    IsRunnable = true,
    Data = [[
local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@param controller FactoryControl.Client.Entities.Controller
local function test(controller)
    -- Test: adding button

    local button = controller:AddButton("Test")
    assert(button, "button is nil")

    log("passed test: adding button")


    -- Test: pressing button

    local pressed = false
    button.OnChanged:AddListener(function()
        pressed = true
    end)

    button:Press()
    while not pressed do
        EventPullAdapter:Wait()
    end

    log("passed test: pressing button")
end

return test
]]
}

PackageData["TestFactoryControlTestsFeaturesSwitch"] = {
    Location = "Test.FactoryControl.Tests.Features.Switch",
    Namespace = "Test.FactoryControl.Tests.Features.Switch",
    IsRunnable = true,
    Data = [[
local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@param controller FactoryControl.Client.Entities.Controller
local function test(controller)
    -- Test: adding switch

    local switch = controller:AddSwitch("Test")
    assert(switch, "switch is nil")

    log("passed test: adding switch")

    -- Test: flipping switch

    local called = false
    local switched = false
    switch.OnChanged:AddListener(function(isEnabled)
        called = true
        if isEnabled then
            switched = isEnabled
        end
    end)

    switch:Toggle()
    while not called do
        EventPullAdapter:Wait()
    end
    assert(switched, "switched is false")

    log("passed test: flipping switch")
end

return test
]]
}

return PackageData
