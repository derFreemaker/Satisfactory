local Network = require("Ficsit-Networks_Sim.Network.Network")

---@class Ficsit_Networks_Sim.Network.SimulatorNetwork
---@field EventNetwork Ficsit_Networks_Sim.Network.Network
---@field private logger Ficsit_Networks_Sim.Utils.Logger
local SimulatorNetwork = {}
SimulatorNetwork.__index = SimulatorNetwork

---@param queueFolderPath Ficsit_Networks_Sim.Filesystem.Path
---@param simulatorId string
---@param loggerConfig Ficsit_Networks_Sim.Config.NetworkConfig
---@return Ficsit_Networks_Sim.Network.SimulatorNetwork
function SimulatorNetwork.new(queueFolderPath, simulatorId, loggerConfig)
    return setmetatable({
        EventNetwork = Network.new(queueFolderPath, simulatorId, loggerConfig.EventNetworkLogger),
        logger = loggerConfig.Logger
    }, SimulatorNetwork)
end



return SimulatorNetwork