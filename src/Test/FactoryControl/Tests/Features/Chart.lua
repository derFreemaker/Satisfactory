local TestFramework = require("Test.Framework.init")
local Helper = require("Test.FactoryControl.Helper")

local Task = require("Core.Common.Task")
local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@param logger Core.Logger
local function overall(logger)
    local controller = Helper.CreateController(logger, "Chart")

    log("adding chart")
    local chart = controller:AddChart(
        "Test",
        {
            Data = { [2] = "lol2" }
        }
    )
    assert(chart, "chart is nil")

    log("adding listener to chart")
    local called = false
    local dataCount = 0
    chart.OnChanged:AddTask(
    ---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Chart.Update
        Task(function(featureUpdate)
            called = true
            dataCount = #chart:GetData() - #featureUpdate.Data
        end)
    )

    log("modifying chart")
    chart:Modify(function(modify)
        modify.Data = { [1] = "lol1" }
    end)
    while not called do
        EventPullAdapter:Wait()
    end
    assert(dataCount == 1, "dataCount is not 1")
end
TestFramework:AddTest("Chart Overall", overall)
