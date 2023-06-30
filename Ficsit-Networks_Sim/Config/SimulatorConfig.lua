local NetworkConfig = require("Ficsit-Networks_Sim.Config.NetworkConfig")
local FileSystemConfig = require("Ficsit-Networks_Sim.Config.FilesystemConfig")
local ComputerConfig = require("Ficsit-Networks_Sim.Config.ComputerConfig")
local ComponentConfig = require("Ficsit-Networks_Sim.Config.ComponentConfig")
local Logger = require("Ficsit-Networks_Sim.Utils.Logger")

-- Loggers are by default with print configured you have to clear the OnLog event first in order to get ride of it.
---@class Ficsit_Networks_Sim.Simulator.Config
---@field NetworkConfig Ficsit_Networks_Sim.Network.Config
---@field FileSystemConfig Ficsit_Networks_Sim.Filesystem.Config
---@field ComputerConfig Ficsit_Networks_Sim.Computer.Config
---@field ComponentConfig Ficsit_Networks_Sim.Component.Config
---@field Logger Ficsit_Networks_Sim.Utils.Logger
local SimulatorConfig = {}
SimulatorConfig.__index = SimulatorConfig

---@param simulator Ficsit_Networks_Sim.Simulator
---@return Ficsit_Networks_Sim.Simulator.Config
function SimulatorConfig.new(simulator)
    local config = setmetatable({}, SimulatorConfig)
    config.Logger = Logger.new("Simulator:'" .. simulator.Id .. "'", 2)
    config.Logger.OnLog:On(print)

    config.NetworkConfig = NetworkConfig.new(simulator.Id, config.Logger, simulator.CurrentDataPath)
    config.FileSystemConfig = FileSystemConfig.new(simulator.CurrentDataPath)
    config.ComputerConfig = ComputerConfig.new()
    config.ComponentConfig = ComponentConfig.new(simulator.SimLibPath)
    return config
end

return SimulatorConfig