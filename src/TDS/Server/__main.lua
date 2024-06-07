local Usage = require("Core.Usage.init")
local Host = require("Hosting.Host")

local TrainEndpoints = require("TDS.Server.Endpoints.TrainEndpoints")
local DatabaseAccessLayer = require("TDS.Server.DatabaseAccessLayer")

---@class TDS.Server.Main : Github_Loading.Entities.Main
---@field m_host Hosting.Host
---@field m_databaseAccessLayer TDS.Server.DatabaseAccessLayer
local Main = {}

function Main:Configure()
    self.m_host = Host(self.Logger:subLogger("Host"), "TrainDistibutionSystem")

    self.m_databaseAccessLayer = DatabaseAccessLayer(self.Logger:subLogger("DatabaseAccessLayer"))

    self.Logger:LogTrace("starting endpoints...")

    self.m_host:AddEndpoint(Usage.Ports.TDS,
        "Trains",
        TrainEndpoints,
        self.m_databaseAccessLayer
    )

    self.Logger:LogDebug("started endpoints")
end

function Main:Run()
    self.m_host:Ready()

    local networkClient = self.m_host:GetNetworkClient()
	while true do
		networkClient:BroadCast(
			Usage.Ports.TDS_Heartbeat,
			Usage.Events.TDS_Heartbeat
		)

		self.m_host:RunCycle(1)

		self.m_databaseAccessLayer:Save()
	end
end

return Main
