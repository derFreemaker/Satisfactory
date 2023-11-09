local TestFramework = require("Test.Framework.Framework")
local Helper = require("Test.FactoryControl.Helper")

local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@param logger Core.Logger
local function overall(logger)
    local controller = Helper.CreateController(logger, "Radial")

    -- Test: adding switch

    local radial = controller:AddRadial("Test")
    assert(radial, "radial is nil")

    log("passed test: adding radial")

    -- Test: flipping switch

    local called = false
    local setting = 0
    ---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Radial.Update
    radial.OnChanged:AddListener(function(featureUpdate)
        called = true
        setting = featureUpdate.Setting
    end)

    radial:Modify(function(modify)
        modify.Setting = 1
    end)
    while not called do
        EventPullAdapter:Wait()
    end
    assert(setting == 1, "setting is not 1")

    log("passed test: update radial")
end
TestFramework:AddTest("Radial Overall", overall)
