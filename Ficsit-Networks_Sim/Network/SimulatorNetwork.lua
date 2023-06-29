local Network = require("Ficsit-Networks_Sim.Network.Network")

---@class Ficsit_Networks_Sim.Network.SimulatorNetwork
---@field EventNetwork Ficsit_Networks_Sim.Network.Network
---@field private logger Ficsit_Networks_Sim.Utils.Logger
local SimulatorNetwork = {}
SimulatorNetwork.__index = SimulatorNetwork

---@param queueFolderPath Ficsit_Networks_Sim.Filesystem.Path
---@param simulatorId string
---@param logger Ficsit_Networks_Sim.Utils.Logger
---@return Ficsit_Networks_Sim.Network.SimulatorNetwork
function SimulatorNetwork.new(queueFolderPath, simulatorId, logger)
    return setmetatable({
        EventNetwork = Network.new(queueFolderPath, simulatorId, logger:create("EventNetwork")),
        logger = logger
    }, SimulatorNetwork)
end



return SimulatorNetwork