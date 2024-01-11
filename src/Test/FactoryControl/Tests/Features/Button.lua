local TestFramework = require("Test.Framework.init")
local Helper = require("Test.FactoryControl.Helper")

local Task = require("Core.Common.Task")
local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@param logger Core.Logger
local function overall(logger)
    local controller = Helper.CreateController(logger, "Button")

    log("adding button")
    local button = controller:AddButton("Test")
    assert(button, "button is nil")

    log("adding listener to button")
    local pressed = false
    button.OnChanged:AddTask(
        Task(function()
            pressed = true
        end)
    )

    log("pressing button")
    button:Press()
    while not pressed do
        EventPullAdapter:Wait()
    end
end
TestFramework:AddTest("Button Overall", overall)
