local PackageData = {}

PackageData.vvWJKhpz = {
    Location = "FactoryControl.Server.__main",
    Namespace = "FactoryControl.Server.__main",
    IsRunnable = true,
    Data = [[
local EventPullAdapter = require('Core.Event.EventPullAdapter')
local NetworkClient = require('Net.Core.NetworkClient')
local RestApiController = require('Net.Rest.Api.Server.Controller')
local ControllerEndpoints = require('FactoryControl.Server.Endpoints.ControllerEndpoints')
local DNSClient = require('DNS.Client.Client')

local Config = require('FactoryControl.Core.Config')

---@class FactoryControl.Server.Main : Github_Loading.Entities.Main
---@field private eventPullAdapter Core.EventPullAdapter
---@field private apiController Net.Rest.Api.Server.Controller
---@field private dnsClient DNS.Client
---@field private netClient Net.Core.NetworkClient
local Main = {}

function Main:Configure()
	self.eventPullAdapter = EventPullAdapter:Initialize(self.Logger:subLogger('EventPullAdapter'))

	self.netClient = NetworkClient(self.Logger:subLogger('NetworkClient'))
	local netPort = self.netClient:CreateNetworkPort(80)
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
	while true do
		self.netClient:BroadCast(53, 'Heartbeat')
		self.eventPullAdapter:WaitForAll(3)
	end
end

return Main
]]
}

PackageData.yarfFUjz = {
    Location = "FactoryControl.Server.Endpoints.ControllerEndpoints",
    Namespace = "FactoryControl.Server.Endpoints.ControllerEndpoints",
    IsRunnable = true,
    Data = [[
local RestApiEndpointBase = require('Net.Rest.Api.Server.EndpointBase')

---@class FactoryControl.Server.Endpoints.ControllerEndpoints : Net.Rest.Api.Server.EndpointBase
local ControllerEndpoints = {}

---@param request Net.Rest.Api.Request
---@return Net.Rest.Api.Response response
function ControllerEndpoints:CREATE__Controller(request)
	return self.Templates:Ok(true)
end

return Utils.Class.CreateClass(ControllerEndpoints, 'FactoryControl.Server.ControllerEndpoints', RestApiEndpointBase)
]]
}

return PackageData
