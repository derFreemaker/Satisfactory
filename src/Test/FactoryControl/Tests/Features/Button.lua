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
