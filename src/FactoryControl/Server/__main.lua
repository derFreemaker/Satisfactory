local Config = require('FactoryControl.Core.Config')
local PortUsage = require('Core.Usage_Port')

local EventPullAdapter = require('Core.Event.EventPullAdapter')
local NetworkClient = require('Net.Core.NetworkClient')
local RestApiController = require('Net.Rest.Api.Server.Controller')

local Database = require("FactoryControl.Server.Database.Controllers")

local ControllerEndpoints = require('FactoryControl.Server.Endpoints.Controller')

local DNSClient = require('DNS.Client.Client')

---@class FactoryControl.Server.Main : Github_Loading.Entities.Main
---@field private eventPullAdapter Core.EventPullAdapter
---@field private apiController Net.Rest.Api.Server.Controller
---@field private dnsClient DNS.Client
---@field private netClient Net.Core.NetworkClient
local Main = {}

function Main:Configure()
	self.eventPullAdapter = EventPullAdapter:Initialize(self._Logger:subLogger('EventPullAdapter'))

	self.netClient = NetworkClient(self._Logger:subLogger('NetworkClient'))
	local netPort = self.netClient:CreateNetworkPort(PortUsage.HTTP)
	netPort:OpenPort()
	self.apiController = RestApiController(netPort, self._Logger:subLogger('RestApiController'))

	local databaseAccessLayer = Database(self._Logger:subLogger("DatabaseAccessLayer"))

	self.apiController:AddRestApiEndpointBase(
		ControllerEndpoints(self._Logger:subLogger("ControllerEndpoints"), databaseAccessLayer))

	self._Logger:LogDebug('setup endpoints')

	self.dnsClient = DNSClient(self.netClient, self._Logger:subLogger('DNSClient'))
	self.dnsClient:CreateAddress(Config.DOMAIN, self.netClient:GetId())
	self._Logger:LogDebug('registered dns client on server')
end

function Main:Run()
	self._Logger:LogInfo('started server')
	self.eventPullAdapter:Run()
end

return Main
