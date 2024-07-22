local Host = require("Hosting.Host")

local DatabaseAccessLayer = require("TDS.Server.DatabaseAccessLayer")
local DistributionSystem = require("TDS.Server.DistributionSystem")

---@class TDS.Server.Main : Github_Loading.Entities.Main
---@field m_host Hosting.Host
---@field m_distibutionSystem TDS.Server.DistributionSystem
---@field m_databaseAccessLayer TDS.Server.DatabaseAccessLayer
local Main = {}

function Main:Configure()
    if not Config.StationId then
        computer.panic("Config.StationId was not set")
    end

    -- add host to host endpoints
    self.m_host = Host(self.Logger:subLogger("Host"))
    ---@using HotReload.Client
    self.m_host:AddHotReload()

    self.m_databaseAccessLayer = DatabaseAccessLayer(self.m_host:GetLogger():subLogger("DatabaseAccessLayer"))

    self.m_distibutionSystem = DistributionSystem(self.m_host:GetLogger():subLogger("TrainDistributionSystem"), self.m_databaseAccessLayer)
end

function Main:Run()
	while true do
        self.m_host:RunCycle(2)

        self.m_distibutionSystem:Cycle()
        self.m_databaseAccessLayer:Save()
	end
end

return Main
