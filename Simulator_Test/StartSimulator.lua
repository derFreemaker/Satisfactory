---@type string, string
local simulatorName, filePath = "Simulator_Test", "Ficsit-Computer.Test.lua"

---@param config Ficsit_Networks_Sim.Simulator.Config
local function Configure(config)
    config.Logger:setLogLevel(0)

    config.ComponentConfig
        :AddComponent("TestColor", "Color", { r = 100 })
        :AddComponent("TestItemType", "ItemType", { name = "Test" })

    config.ComputerConfig:AddPCIDevice("TestObject", "FINComputerGPU", { Name = "Hi" })
    return true
end

-- ######### don't touch that ######## --
local sim = require("Ficsit-Networks_Sim.Simulator")
sim = sim.new(Configure, simulatorName, filePath)
sim:Run()