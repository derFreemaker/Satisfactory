local Logger = require("Ficsit-Networks_Sim.Utils.Logger")

---@class Ficsit_Networks_Sim.Network.Config
---@field SimulatorId string
---@field NetworkDataPath string
---@field Logger Ficsit_Networks_Sim.Utils.Logger
---@field EventNetworkLogger Ficsit_Networks_Sim.Utils.Logger
local NetworkConfig = {}
NetworkConfig.__index = NetworkConfig

---@param simulatorId string
---@param simulatorLogger Ficsit_Networks_Sim.Utils.Logger
---@param dataPath Ficsit_Networks_Sim.Filesystem.Path
---@return Ficsit_Networks_Sim.Network.Config
function NetworkConfig.new(simulatorId, simulatorLogger, dataPath)
    local config = setmetatable({}, NetworkConfig)
    config.SimulatorId = simulatorId
    config.Logger = simulatorLogger:create("Network")
    config.EventNetworkLogger = config.Logger:create("EventNetwork")
    config.NetworkDataPath = dataPath:Extend("Network"):GetPath()
    return config
end

return NetworkConfig
