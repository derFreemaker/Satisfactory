local TestFramework = require("Test.Framework.init")
local Helper = require("Test.FactoryControl.Helper")

local Task = require("Core.Common.Task")
local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@param logger Core.Logger
local function overall(logger)
    local controller = Helper.CreateController(logger, "Radial")

    log("adding radial")
    local radial = controller:AddRadial("Test")
    assert(radial, "radial is nil")

    log("adding listener to radial")
    local called = false
    local setting = 0
    radial.OnChanged:AddTask(
    ---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Radial.Update
        Task(function(featureUpdate)
            called = true
            setting = featureUpdate.Setting
        end)
    )

    log("modifying radial")
    radial:Modify(function(modify)
        modify.Setting = 1
    end)
    while not called do
        EventPullAdapter:Wait()
    end
    assert(setting == 1, "setting is not 1")
end
TestFramework:AddTest("Radial Overall", overall)
