local Network = require("Ficsit-Networks_Sim.Network.Network")
local Path = require("Ficsit-Networks_Sim.Filesystem.Path")

---@class Ficsit_Networks_Sim.Network.SimulatorNetwork
---@field EventNetwork Ficsit_Networks_Sim.Network.Network
---@field private logger Ficsit_Networks_Sim.Utils.Logger
local SimulatorNetwork = {}
SimulatorNetwork.__index = SimulatorNetwork

---@param config Ficsit_Networks_Sim.Network.Config
---@return Ficsit_Networks_Sim.Network.SimulatorNetwork
function SimulatorNetwork.new(config)
    return setmetatable({
        EventNetwork = Network.new(Path.new(config.NetworkDataPath), config.SimulatorId, config.EventNetworkLogger),
        logger = config.Logger
    }, SimulatorNetwork)
end



return SimulatorNetwork