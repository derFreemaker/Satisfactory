local Config = require('FactoryControl.Core.Config')
local PortUsage = require('Core.Usage.Usage_Port')

local EventPullAdapter = require('Core.Event.EventPullAdapter')
local NetworkClient = require('Net.Core.NetworkClient')
local RestApiController = require('Net.Rest.Api.Server.Controller')

local Database = require("FactoryControl.Server.Database.Controllers")

local ControllerEndpoints = require('FactoryControl.Server.Endpoints.Controller')

local DNSClient = require('DNS.Client.Client')

---@class FactoryControl.Server.Main : Github_Loading.Entities.Main
---@field private _EventPullAdapter Core.EventPullAdapter
---@field private _ApiController Net.Rest.Api.Server.Controller
---@field private _DnsClient DNS.Client
---@field private _NetClient Net.Core.NetworkClient
local Main = {}

function Main:Configure()
	self._EventPullAdapter = EventPullAdapter:Initialize(self.Logger:subLogger('EventPullAdapter'))

	self._NetClient = NetworkClient(self.Logger:subLogger('NetworkClient'))
	local netPort = self._NetClient:GetOrCreateNetworkPort(PortUsage.HTTP)
	netPort:OpenPort()
	self._ApiController = RestApiController(netPort, self.Logger:subLogger('RestApiController'))

	local databaseAccessLayer = Database(self.Logger:subLogger("DatabaseAccessLayer"))

	self._ApiController:AddEndpointBase(
		ControllerEndpoints(self.Logger:subLogger("ControllerEndpoints"), databaseAccessLayer))

	self.Logger:LogDebug('setup endpoints')

	self._DnsClient = DNSClient(self._NetClient, self.Logger:subLogger('DNSClient'))
	self._DnsClient:CreateAddress(Config.DOMAIN, self._NetClient:GetIPAddress())
	self.Logger:LogDebug('registered dns client on server')
end

function Main:Run()
	self.Logger:LogInfo('started server')
	self._EventPullAdapter:Run()
end

return Main
