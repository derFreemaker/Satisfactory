local TestFramework = require("Test.Framework.init")
local Helper = require("Test.FactoryControl.Helper")

local Task = require("Core.Common.Task")
local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@param logger Core.Logger
local function controlling(logger)
    local client = Helper.CreateFactoryControlClient(logger)

    log("create controller")
    local controller = client:Connect("Controlling")

    log("adding button")
    local featureName = "test"
    local button = controller:AddButton(featureName)
    assert(button, "could not add button")
    local pressed = false
    button.OnChanged:AddTask(
        Task(function()
            pressed = true
        end)
    )

    log("getting controller")
    local gotController = client:GetControllerByName("Controlling")
    if not gotController then
        log("could not get controller by name")
        gotController = client:GetControllerById(controller.Id)
    end
    assert(gotController, "could not get controller")

    log("getting button")
    local feature = gotController:GetFeatureByName(featureName)
    assert(feature, "could not get feature")
    ---@cast feature FactoryControl.Client.Entities.Controller.Feature.Button

    log("pressing button")
    feature:Press()

    button:Press()
    while not pressed do
        EventPullAdapter:Wait()
    end
end
TestFramework:AddTest("Controlling", controlling)
