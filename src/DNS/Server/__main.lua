local DNSEndpoints = require('DNS.Server.Endpoints')
local NetworkClient = require('Net.Core.NetworkClient')
local Task = require('Core.Task')
local RestApiController = require('Net.Rest.Api.Server.Controller')

---@class DNS.Main : Github_Loading.Entities.Main
---@field private eventPullAdapter Core.EventPullAdapter
---@field private apiController Net.Rest.Api.Server.Controller
---@field private netPort Net.Core.NetworkPort
---@field private endpoints DNS.Endpoints
local Main = {}

---@param context Net.Core.NetworkContext
function Main:GetDNSServerAddress(context)
	local netClient = self.netPort:GetNetClient()
	local id = netClient:GetId()
	self.Logger:LogDebug(context.SenderIPAddress .. ' requested DNS Server IP Address')
	netClient:SendMessage(context.SenderIPAddress, 53, 'ReturnDNSServerAddress', id)
end

function Main:Configure()
	self.eventPullAdapter = require('Core.Event.EventPullAdapter'):Initialize(self.Logger:subLogger('EventPullAdapter'))

	local dnsLogger = self.Logger:subLogger('DNSServerAddress')
	local netClient = NetworkClient(dnsLogger:subLogger('NetworkClient'))
	self.netPort = netClient:CreateNetworkPort(53)
	self.netPort:AddListener('GetDNSServerAddress', Task(self.GetDNSServerAddress, self))
	self.netPort:OpenPort()
	self.Logger:LogDebug('setup Get DNS Server IP Address')

	self.Logger:LogTrace('setting up DNS Server endpoints...')
	local endpointLogger = self.Logger:subLogger('Endpoints')
	local netPort = netClient:CreateNetworkPort(80)
	self.apiController = RestApiController(netPort, endpointLogger:subLogger('ApiController'))
	self.endpoints = DNSEndpoints(endpointLogger)
	self.apiController:AddRestApiEndpointBase(self.endpoints)
	netPort:OpenPort()
	self.Logger:LogDebug('setup DNS Server endpoints')
end

function Main:Run()
	self.Logger:LogInfo('started DNS Server')
	self.eventPullAdapter:Run()
end

return Main
