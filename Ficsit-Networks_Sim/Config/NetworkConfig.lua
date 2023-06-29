local Logger = require("Ficsit-Networks_Sim.Utils.Logger")

---@class Ficsit_Networks_Sim.Config.NetworkConfig
---@field Logger Ficsit_Networks_Sim.Utils.Logger
---@field EventNetworkLogger Ficsit_Networks_Sim.Utils.Logger
local NetworkConfig = {}
NetworkConfig.__index = NetworkConfig

---@param simulatorLogger Ficsit_Networks_Sim.Utils.Logger
---@return Ficsit_Networks_Sim.Config.NetworkConfig
function NetworkConfig.new(simulatorLogger)
    local config = setmetatable({}, NetworkConfig)
    config.Logger = simulatorLogger:create("Network")
    config.EventNetworkLogger = config.Logger:create("EventNetwork")
    return config
end

return NetworkConfig
