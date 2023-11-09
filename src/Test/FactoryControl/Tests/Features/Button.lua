local TestFramework = require("Test.Framework.Framework")
local Helper = require("Test.FactoryControl.Helper")

local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@param logger Core.Logger
local function overall(logger)
    local controller = Helper.CreateController(logger, "Button")

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
TestFramework:AddTest("Button Overall", overall)
