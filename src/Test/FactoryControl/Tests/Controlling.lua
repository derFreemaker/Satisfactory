local TestFramework = require("Test.Framework.Framework")
local Helper = require("Test.FactoryControl.Helper")

local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@param logger Core.Logger
local function controlling(logger)
    local client = Helper.CreateFactoryControlClient(logger)

    local controller = client:Connect("Controlling")

    local featureName = "test"
    local button = controller:AddButton(featureName)
    assert(button, "could not add button")
    local pressed = false
    button.OnChanged:AddListener(function()
        pressed = true
    end)

    local getedController = client:GetControllerByName("Controlling") or client:GetControllerById(controller.Id)
    assert(getedController, "could not get controller")

    local features = getedController:GetFeatures()
    for _, feature in pairs(features) do
        if feature.Name == featureName then
            ---@cast feature FactoryControl.Client.Entities.Controller.Feature.Button
            feature:Press()
        end
    end

    button:Press()
    while not pressed do
        EventPullAdapter:Wait()
    end
end
TestFramework:AddTest("Controlling", controlling)
