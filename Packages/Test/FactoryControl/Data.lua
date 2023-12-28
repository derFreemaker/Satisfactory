local Data={
["Test.FactoryControl.__main"] = [[
local Host = require("Hosting.Host")

---@class FactoryControl.Test.Main : Github_Loading.Entities.Main
---@field private m_host Hosting.Host
---@field private m_testFramework Test.Framework
local Main = {}

function Main:Configure()
    self.m_host = Host(self.Logger:subLogger("Host"), "Host")

    self.m_testFramework = self.m_host:AddTesting()
end

function Main:Run()
    self.m_testFramework:Run(self.Logger:subLogger("TestFramework"))
end

return Main

]],
["Test.FactoryControl.Helper"] = [[
local NetworkClient = require("Net.Core.NetworkClient")

local FacotryControlClient = require("FactoryControl.Client.Client")

---@class Test.FacotryControl.Helper : object
local Helper = {}

---@param logger Core.Logger
---@return FactoryControl.Client
function Helper.CreateFactoryControlClient(logger)
    return FacotryControlClient(logger:subLogger("Client"), nil, NetworkClient(logger:subLogger("NetworkClient")))
end

---@param logger Core.Logger
---@param name string
---@return FactoryControl.Client.Entities.Controller
function Helper.CreateController(logger, name)
    local client = Helper.CreateFactoryControlClient(logger)
    return client:Connect(name)
end

return Helper

]],
["Test.FactoryControl.Tests.Connection"] = [[
local TestFramework = require("Test.Framework.init")
local Helper = require("Test.FactoryControl.Helper")

---@param logger Core.Logger
local function connection(logger)
    local client = Helper.CreateFactoryControlClient(logger)

    log("connecting...")
    local controller = client:Connect("Connection")

    assert(controller.IPAddress:Equals(client.NetClient:GetIPAddress()), "IP Address mismatch")
end
TestFramework:AddTest("Connection", connection)

]],
["Test.FactoryControl.Tests.Controlling"] = [[
local TestFramework = require("Test.Framework.init")
local Helper = require("Test.FactoryControl.Helper")

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
    button.OnChanged:AddListener(function()
        pressed = true
    end)

    log("getting controller")
    local getedController = client:GetControllerByName("Controlling")
    if not getedController then
        log("could not get controller by name")
        getedController = client:GetControllerById(controller.Id)
    end
    assert(getedController, "could not get controller")

    log("getting button")
    local feature = getedController:GetFeatureByName(featureName)
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

]],
["Test.FactoryControl.Tests.Features.Button"] = [[
local TestFramework = require("Test.Framework.init")
local Helper = require("Test.FactoryControl.Helper")

local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@param logger Core.Logger
local function overall(logger)
    local controller = Helper.CreateController(logger, "Button")

    log("adding button")
    local button = controller:AddButton("Test")
    assert(button, "button is nil")

    log("adding listener to button")
    local pressed = false
    button.OnChanged:AddListener(function()
        pressed = true
    end)

    log("pressing button")
    button:Press()
    while not pressed do
        EventPullAdapter:Wait()
    end
end
TestFramework:AddTest("Button Overall", overall)

]],
["Test.FactoryControl.Tests.Features.Chart"] = [[
local TestFramework = require("Test.Framework.init")
local Helper = require("Test.FactoryControl.Helper")

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
    ---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Chart.Update
    chart.OnChanged:AddListener(function(featureUpdate)
        called = true
        dataCount = #chart:GetData() - #featureUpdate.Data
    end)

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

]],
["Test.FactoryControl.Tests.Features.Radial"] = [[
local TestFramework = require("Test.Framework.init")
local Helper = require("Test.FactoryControl.Helper")

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
    ---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Radial.Update
    radial.OnChanged:AddListener(function(featureUpdate)
        called = true
        setting = featureUpdate.Setting
    end)

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

]],
["Test.FactoryControl.Tests.Features.Switch"] = [[
local TestFramework = require("Test.Framework.init")
local Helper = require("Test.FactoryControl.Helper")

local EventPullAdapter = require("Core.Event.EventPullAdapter")

---@param logger Core.Logger
local function overall(logger)
    local controller = Helper.CreateController(logger, "Switch")

    log("adding switch")
    local switch = controller:AddSwitch("Test")
    assert(switch, "switch is nil")

    log("adding listener to switch")
    local called = false
    local switched = false
    switch.OnChanged:AddListener(function(isEnabled)
        called = true
        if isEnabled then
            switched = isEnabled
        end
    end)

    log("toggling switch")
    switch:Toggle()
    while not called do
        EventPullAdapter:Wait()
    end
    assert(switched, "switched is false")
end
TestFramework:AddTest("Switch Overall", overall)

]],
}

return Data
