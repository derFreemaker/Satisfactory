local PortUsage = require('Core.Usage_Port')
local EventNameUsage = require("Core.Usage_EventName")

local DNSEndpoints = require('DNS.Server.Endpoints')
local NetworkClient = require('Net.Core.NetworkClient')
local Task = require('Core.Task')
local RestApiController = require('Net.Rest.Api.Server.Controller')

---@class DNS.Main : Github_Loading.Entities.Main
---@field private _EventPullAdapter Core.EventPullAdapter
---@field private _ApiController Net.Rest.Api.Server.Controller
---@field private _NetPort Net.Core.NetworkPort
---@field private _NetClient Net.Core.NetworkClient
---@field private _Endpoints DNS.Endpoints
local Main = {}

---@param context Net.Core.NetworkContext
function Main:GetDNSServerAddress(context)
	local netClient = self._NetPort:GetNetClient()
	local id = netClient:GetId()
	self.Logger:LogDebug(context.SenderIPAddress .. ' requested DNS Server IP Address')
	netClient:Send(context.SenderIPAddress, PortUsage.DNS, EventNameUsage.DNS_ReturnServerAddress, id)
end

function Main:Configure()
	self._EventPullAdapter = require('Core.Event.EventPullAdapter'):Initialize(self.Logger:subLogger('EventPullAdapter'))

	local dnsLogger = self.Logger:subLogger('DNSServerAddress')
	self._NetClient = NetworkClient(dnsLogger:subLogger('NetworkClient'))
	self._NetPort = self._NetClient:CreateNetworkPort(PortUsage.DNS)
	self._NetPort:AddListener('GetDNSServerAddress', Task(self.GetDNSServerAddress, self))
	self._NetPort:OpenPort()
	self.Logger:LogDebug('setup Get DNS Server IP Address')

	self.Logger:LogTrace('setting up DNS Server endpoints...')
	local endpointLogger = self.Logger:subLogger('Endpoints')
	local netPort = self._NetClient:CreateNetworkPort(PortUsage.HTTP)
	self._ApiController = RestApiController(netPort, endpointLogger:subLogger('ApiController'))
	self._Endpoints = DNSEndpoints(endpointLogger)
	self._ApiController:AddRestApiEndpointBase(self._Endpoints)
	netPort:OpenPort()
	self.Logger:LogDebug('setup DNS Server endpoints')
end

function Main:Run()
	self.Logger:LogInfo('started DNS Server')
	while true do
		self._NetClient:BroadCast(PortUsage.Heartbeats, 'DNS')
		self._EventPullAdapter:WaitForAll(3)
	end
end

return Main
