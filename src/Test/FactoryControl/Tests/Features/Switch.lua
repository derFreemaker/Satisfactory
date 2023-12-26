local TestFramework = require("Test.Framework.init")
local Helper = require("Test.FactoryControl.Helper")

local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@param logger Core.Logger
local function overall(logger)
    local controller = Helper.CreateController(logger, "Switch")

    log("adding switch")
    local switch = controller:AddSwitch("Test")
    assert(switch, "switch is nil")

    log("adding listener to switch")
    local called = false
    local switched = false
    switch.OnChanged:AddListener(function(isEnabled)
        called = true
        if isEnabled then
            switched = isEnabled
        end
    end)

    log("toggling switch")
    switch:Toggle()
    while not called do
        EventPullAdapter:Wait()
    end
    assert(switched, "switched is false")
end
TestFramework:AddTest("Switch Overall", overall)
