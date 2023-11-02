local Config = require('FactoryControl.Core.Config')
local Usage = require('Core.Usage.Usage')

local DatabaseAccessLayer = require("FactoryControl.Server.DatabaseAccessLayer")

local ControllerEndpoints = require('FactoryControl.Server.Endpoints.Controller')
local FeatureEndpoints = require("FactoryControl.Server.Endpoints.Feature")

local Host = require('Hosting.Host')

---@class FactoryControl.Server.Main : Github_Loading.Entities.Main
---@field private m_host Hosting.Host
local Main = {}

function Main:Configure()
	self.m_host = Host(self.Logger:subLogger('Host'), "FactoryControl Server")

	local databaseAccessLayer = DatabaseAccessLayer(self.Logger:subLogger("DatabaseAccessLayer"))

	self.m_host:AddEndpoint(Usage.Ports.HTTP,
		"Controller",
		ControllerEndpoints --[[@as FactoryControl.Server.Endpoints.Controller]],
		databaseAccessLayer)

	self.m_host:AddEndpoint(Usage.Ports.HTTP,
		"Feature",
		FeatureEndpoints,
		databaseAccessLayer)

	self.Logger:LogDebug('setup endpoints')

	self.m_host:RegisterAddress(Config.DOMAIN)
end

function Main:Run()
	self.m_host:Ready()
	while true do
		self.m_host:GetNetworkClient():BroadCast(
			Usage.Ports.FactoryControl_Heartbeat,
			Usage.Events.FactoryControl_Heartbeat)

		self.m_host:RunCycle(3)
	end
end

return Main
