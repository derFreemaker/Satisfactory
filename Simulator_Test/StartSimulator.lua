---@type string, string
local simulatorName, filePath = "Simulator_Test", "Ficsit-Computer.Test.lua"

---@param config Ficsit_Networks_Sim.SimulatorConfig
local function Configure(config)
    config.ComponentConfig
        :AddComponent("TestColor", "Color", { r = 100 })
        :AddComponent("TestItemType", "ItemType", { name = "Test" })
    return true
end



-- ######### don't touch that ######## --
local sim = require("Ficsit-Networks_Sim.Simulator")
sim = sim.new(Configure, simulatorName, filePath)
sim:Run()