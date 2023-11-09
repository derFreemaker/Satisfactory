local TestFramework = require("Test.Framework.Framework")
local Helper = require("Test.FactoryControl.Helper")

local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@param logger Core.Logger
local function overall(logger)
    local controller = Helper.CreateController(logger, "Chart")

    -- Test: adding switch

    local chart = controller:AddChart(
        "Test",
        {
            Data = { [2] = "lol2" }
        }
    )
    assert(chart, "chart is nil")

    log("passed test: adding chart")

    -- Test: flipping switch

    local called = false
    local dataCount = 0
    ---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Chart.Update
    chart.OnChanged:AddListener(function(featureUpdate)
        called = true
        dataCount = #chart:GetData() - #featureUpdate.Data
    end)

    chart:Modify(function(modify)
        modify.Data = { [1] = "lol1" }
    end)
    while not called do
        EventPullAdapter:Wait()
    end
    assert(dataCount == 1, "dataCount is not 1")

    log("passed test: update chart")
end
TestFramework:AddTest("Chart Overall", overall)
