---@type string
local filePath = "Ficsit-Computer.Test.lua"

---@type string
local simulatorName = "Simulator_Test"

---@type Ficsit_Networks_Sim.Utils.Logger.LogLevel
local logLevel = 2

---@param config Ficsit_Networks_Sim.SimulatorConfig
local function Configure(config)
    config.SimulatorLogger.OnLog:On(function(message) print(message) end)

    config.ComponentConfig
        :AddComponent("TestColor", "Color", { r = 100 })
        :AddComponent("TestItemType", "ItemType", { name = "Test" })
    return true
end



-- ######### don't touch that ######## --
local source = debug.getinfo(1, "S").source:gsub("\\", "/"):gsub("@", "")
local slashPos = source:reverse():find("/")
local lenght = source:len()
local path = source:sub(0, lenght - slashPos)

local Simulator = require("Ficsit-Networks_Sim.Simulator")
local sim = Simulator.new(Configure, simulatorName, filePath, path, logLevel)
sim:Run()