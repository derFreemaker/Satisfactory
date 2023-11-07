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
