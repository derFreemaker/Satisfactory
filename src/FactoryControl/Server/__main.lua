---@using DNS.Client

local Config = require("FactoryControl.Core.Config")
local Usage = require("Core.Usage.init")

local DatabaseAccessLayer = require("FactoryControl.Server.DatabaseAccessLayer")

local ControllerEndpoints = require("FactoryControl.Server.Endpoints.Controller")
local FeatureEndpoints = require("FactoryControl.Server.Endpoints.Feature")

local CallbackService = require("Services.Callback.Server.CallbackService")
local FeatureService = require("FactoryControl.Server.Services.FeatureService")

local Host = require("Hosting.Host")

---@class FactoryControl.Server.Main : Github_Loading.Entities.Main
---@field private m_host Hosting.Host
---@field private m_databaseAccessLayer FactoryControl.Server.DatabaseAccessLayer
local Main = {}

function Main:Configure()
	self.m_host = Host(self.Logger:subLogger("Host"), "FactoryControl Server")

	self.m_databaseAccessLayer = DatabaseAccessLayer(self.Logger:subLogger("DatabaseAccessLayer"))

	local networkClient = self.m_host:GetNetworkClient()
	local callbackService = CallbackService(self.m_host:CreateLogger("CallbackService"), networkClient)
	local featureService = FeatureService(callbackService, self.m_databaseAccessLayer, networkClient)
	self.m_host.Services:AddService(featureService)
	self.m_host:AddCallableEventTask(
		Usage.Events.FactoryControl_Feature_Update,
		Usage.Ports.FactoryControl,
		featureService.OnFeatureInvoked
	)

	self.Logger:LogDebug("started services")

	self.m_host:AddEndpoint(Usage.Ports.HTTP,
		"Controller",
		ControllerEndpoints,
		self.m_databaseAccessLayer
	)

	self.m_host:AddEndpoint(Usage.Ports.HTTP,
		"Feature",
		FeatureEndpoints,
		self.m_databaseAccessLayer,
		featureService
	)

	self.Logger:LogDebug("setup endpoints")

	self.m_host:RegisterAddress(Config.DOMAIN)
end

function Main:Run()
	self.m_host:Ready()

	local networkClient = self.m_host:GetNetworkClient()
	while true do
		networkClient:BroadCast(
			Usage.Ports.FactoryControl_Heartbeat,
			Usage.Events.FactoryControl_Heartbeat
		)

		self.m_host:RunCycle(1)

		self.m_databaseAccessLayer:Save()
	end
end

return Main
