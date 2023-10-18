local PortUsage = require('Core.Usage_Port')
local EventNameUsage = require("Core.Usage_EventName")

local DNSEndpoints = require('DNS.Server.Endpoints')
local NetworkClient = require('Net.Core.NetworkClient')
local Task = require('Core.Task')
local RestApiController = require('Net.Rest.Api.Server.Controller')

---@class DNS.Main : Github_Loading.Entities.Main
---@field private eventPullAdapter Core.EventPullAdapter
---@field private apiController Net.Rest.Api.Server.Controller
---@field private netPort Net.Core.NetworkPort
---@field private netClient Net.Core.NetworkClient
---@field private endpoints DNS.Endpoints
local Main = {}

---@param context Net.Core.NetworkContext
function Main:GetDNSServerAddress(context)
	local netClient = self.netPort:GetNetClient()
	local id = netClient:GetId()
	self._Logger:LogDebug(context.SenderIPAddress .. ' requested DNS Server IP Address')
	netClient:Send(context.SenderIPAddress, PortUsage.DNS, EventNameUsage.DNS_ReturnServerAddress, id)
end

function Main:Configure()
	self.eventPullAdapter = require('Core.Event.EventPullAdapter'):Initialize(self._Logger:subLogger('EventPullAdapter'))

	local dnsLogger = self._Logger:subLogger('DNSServerAddress')
	self.netClient = NetworkClient(dnsLogger:subLogger('NetworkClient'))
	self.netPort = self.netClient:CreateNetworkPort(PortUsage.DNS)
	self.netPort:AddListener('GetDNSServerAddress', Task(self.GetDNSServerAddress, self))
	self.netPort:OpenPort()
	self._Logger:LogDebug('setup Get DNS Server IP Address')

	self._Logger:LogTrace('setting up DNS Server endpoints...')
	local endpointLogger = self._Logger:subLogger('Endpoints')
	local netPort = self.netClient:CreateNetworkPort(PortUsage.HTTP)
	self.apiController = RestApiController(netPort, endpointLogger:subLogger('ApiController'))
	self.endpoints = DNSEndpoints(endpointLogger)
	self.apiController:AddRestApiEndpointBase(self.endpoints)
	netPort:OpenPort()
	self._Logger:LogDebug('setup DNS Server endpoints')
end

function Main:Run()
	self._Logger:LogInfo('started DNS Server')
	while true do
		self.netClient:BroadCast(PortUsage.Heartbeats, 'DNS')
		self.eventPullAdapter:WaitForAll(3)
	end
end

return Main
