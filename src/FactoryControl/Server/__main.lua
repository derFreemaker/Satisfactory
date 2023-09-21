local Config = require('FactoryControl.Core.Config')
local PortUsage = require('Core.PortUsage')

local EventPullAdapter = require('Core.Event.EventPullAdapter')
local NetworkClient = require('Net.Core.NetworkClient')
local RestApiController = require('Net.Rest.Api.Server.Controller')
local ControllerEndpoints = require('FactoryControl.Server.Endpoints.ControllerEndpoints')
local DNSClient = require('DNS.Client.Client')

---@class FactoryControl.Server.Main : Github_Loading.Entities.Main
---@field private eventPullAdapter Core.EventPullAdapter
---@field private apiController Net.Rest.Api.Server.Controller
---@field private dnsClient DNS.Client
---@field private netClient Net.Core.NetworkClient
local Main = {}

function Main:Configure()
	self.eventPullAdapter = EventPullAdapter:Initialize(self.Logger:subLogger('EventPullAdapter'))

	self.netClient = NetworkClient(self.Logger:subLogger('NetworkClient'))
	local netPort = self.netClient:CreateNetworkPort(PortUsage.HTTP)
	netPort:OpenPort()
	self.apiController = RestApiController(netPort, self.Logger:subLogger('RestApiController'))
	self.apiController:AddRestApiEndpointBase(ControllerEndpoints())
	self.Logger:LogDebug('setup endpoints')

	self.dnsClient = DNSClient(self.netClient, self.Logger:subLogger('DNSClient'))
	self.dnsClient:CreateAddress(Config.DOMAIN, self.netClient:GetId())
	self.Logger:LogDebug('registered dns client on server')
end

function Main:Run()
	self.Logger:LogInfo('started server')
	self.eventPullAdapter:WaitForAll()
end

return Main
