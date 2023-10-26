local Config = require('FactoryControl.Core.Config')
local PortUsage = require('Core.Usage.Usage_Port')

local EventPullAdapter = require('Core.Event.EventPullAdapter')
local NetworkClient = require('Net.Core.NetworkClient')
local RestApiController = require('Net.Rest.Api.Server.Controller')

local Database = require("FactoryControl.Server.Database.Controllers")

local ControllerEndpoints = require('FactoryControl.Server.Endpoints.Controller')

local DNSClient = require('DNS.Client.Client')

local Host = require('Hosting.Host')

---@class FactoryControl.Server.Main : Github_Loading.Entities.Main
---@field private m_host Hosting.Host
---@field private m_eventPullAdapter Core.EventPullAdapter
---@field private m_apiController Net.Rest.Api.Server.Controller
---@field private m_dnsClient DNS.Client
---@field private m_netClient Net.Core.NetworkClient
local Main = {}

function Main:Configure()
	self.m_host = Host(self.Logger:subLogger('Host'))

	local databaseAccessLayer = Database(self.Logger:subLogger("DatabaseAccessLayer"))

	self.m_host:AddEndpoint(PortUsage.HTTP,
		"Controller",
		ControllerEndpoints --[[@as FactoryControl.Server.Endpoints.ControllerEndpoints]],
		databaseAccessLayer)
	self.Logger:LogDebug('setup endpoints')

	self.m_host:RegisterAddress(Config.DOMAIN)
end

function Main:Run()
	self.Logger:LogInfo('started server')
	self.m_host:Run()
end

return Main
