local EventPullAdapter = require("Core.Event.EventPullAdapter")
local Host = require("Hosting.Host")

local DistributionSystem = require("TDS.Server.DistributionSystem")

---@class TDS.Server.Main : Github_Loading.Entities.Main
---@field m_host Hosting.Host
---@field m_distibutionSystem TDS.Server.DistributionSystem
local Main = {}

function Main:Configure()
    if not Config.StationId then
        computer.panic("Config.StationId was not set")
    end

    -- add host to host endpoints
    self.m_host = Host(self.Logger:subLogger("Host"))
    ---@using HotReload.Client
    self.m_host:AddHotReload()

    self.m_distibutionSystem = DistributionSystem(self.Logger:subLogger("TrainDistributionSystem"))
end

function Main:Run()
	while true do
        self.m_host:RunCycle(2)

        self.m_distibutionSystem:Cycle()
	end
end

return Main
