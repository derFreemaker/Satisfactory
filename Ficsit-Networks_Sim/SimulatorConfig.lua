local FileSystemConfig = require("Ficsit-Networks_Sim.Filesystem.FilesystemConfig")
local ComponentConfig = require("Ficsit-Networks_Sim.Component.ComponentConfig")

---@class Ficsit_Networks_Sim.SimulatorConfig
---@field FileSystemConfig Ficsit_Networks_Sim.Filesystem.Config
---@field ComponentConfig Ficsit_Networks_Sim.Component.Config
---@field SimulatorLogger Ficsit_Networks_Sim.Utils.Logger
local SimulatorConfig = {}
SimulatorConfig.__index = SimulatorConfig

---@param simLogger Ficsit_Networks_Sim.Utils.Logger
function SimulatorConfig.new(simLogger)
    return setmetatable({
        FileSystemConfig = FileSystemConfig.new(),
        ComponentConfig = ComponentConfig.new(),
        SimulatorLogger = simLogger
    }, SimulatorConfig)
end

return SimulatorConfig