local TestFramework = require("Test.Framework.Framework")
local Helper = require("Test.FactoryControl.Helper")

local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@param logger Core.Logger
local function overall(logger)
    local controller = Helper.CreateController(logger, "Switch")

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
TestFramework:AddTest("Switch Overall", overall)
