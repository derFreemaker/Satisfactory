local NetworkConfig = require("Ficsit-Networks_Sim.Config.NetworkConfig")
local FileSystemConfig = require("Ficsit-Networks_Sim.Config.FilesystemConfig")
local ComponentConfig = require("Ficsit-Networks_Sim.Config.ComponentConfig")
local Logger = require("Ficsit-Networks_Sim.Utils.Logger")

-- Loggers are by default with print configured you have to clear the OnLog event first in order to get ride of it.
---@class Ficsit_Networks_Sim.SimulatorConfig
---@field NetworkConfig Ficsit_Networks_Sim.Config.NetworkConfig
---@field FileSystemConfig Ficsit_Networks_Sim.Filesystem.Config
---@field ComponentConfig Ficsit_Networks_Sim.Component.Config
---@field Logger Ficsit_Networks_Sim.Utils.Logger
local SimulatorConfig = {}
SimulatorConfig.__index = SimulatorConfig

---@param simulatorId string
---@return Ficsit_Networks_Sim.SimulatorConfig
function SimulatorConfig.new(simulatorId)
    local config = setmetatable({}, SimulatorConfig)
    config.Logger = Logger.new("Simulator:'" .. simulatorId .. "'", 2)
    config.Logger.OnLog:On(print)

    config.NetworkConfig = NetworkConfig.new(config.Logger)
    config.FileSystemConfig = FileSystemConfig.new()
    config.ComponentConfig = ComponentConfig.new()
    return config
end

return SimulatorConfig