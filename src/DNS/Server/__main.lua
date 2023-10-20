local Usage = require("Core.Usage.Usage")

local Task = require('Core.Task')

local Host = require("Hosting.Host")

local DNSEndpoints = require('DNS.Server.Endpoints')

---@class DNS.Main : Github_Loading.Entities.Main
---@field private _ApiController Net.Rest.Api.Server.Controller
---@field private _NetPort Net.Core.NetworkPort
---@field private _NetClient Net.Core.NetworkClient
---@field private _Endpoints DNS.Endpoints
---
---@field private _Host Hosting.Host
local Main = {}

---@param context Net.Core.NetworkContext
function Main:GetDNSServerAddress(context)
	local netClient = self._NetPort:GetNetClient()
	local id = netClient:GetIPAddress():GetAddress()
	self.Logger:LogDebug(context.SenderIPAddress .. ' requested DNS Server IP Address')
	netClient:Send(context.SenderIPAddress, Usage.Ports.DNS, Usage.Events.DNS_ReturnServerAddress, id)
end

function Main:Configure()
	self._Host = Host(self.Logger:subLogger("Host"), "DNS")

	self._Host:AddCallableEvent("GetDNSServerAddress", Usage.Ports.DNS, Task(self.GetDNSServerAddress, self))
	self.Logger:LogDebug('setup Get DNS Server IP Address')

	local endpointLogger = self.Logger:subLogger("Endpoints")
	self._Host:AddEndpointBase(Usage.Ports.HTTP, endpointLogger, DNSEndpoints(endpointLogger))
	self.Logger:LogDebug('setup DNS Server endpoints')
end

function Main:Run()
	self._Host:Ready()
	while true do
		self._NetClient:BroadCast(Usage.Ports.Heartbeats, 'DNS')
		self._Host:RunCycle(3)
	end
end

return Main
