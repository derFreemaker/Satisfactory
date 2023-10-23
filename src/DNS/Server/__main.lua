local Usage = require("Core.Usage.Usage")

local Task = require('Core.Task')

local Host = require("Hosting.Host")

local DNSEndpoints = require('DNS.Server.Endpoints')

---@class DNS.Main : Github_Loading.Entities.Main
---@field private _NetClient Net.Core.NetworkClient
---@field private _Host Hosting.Host
local Main = {}

---@param context Net.Core.NetworkContext
function Main:GetDNSServerAddress(context)
	local id = self._NetClient:GetIPAddress():GetAddress()
	self.Logger:LogDebug(context.SenderIPAddress, 'requested DNS Server IP Address')
	self._NetClient:Send(context.SenderIPAddress, Usage.Ports.DNS, Usage.Events.DNS_ReturnServerAddress, id)
end

function Main:Configure()
	self._Host = Host(self.Logger:subLogger("Host"), "DNS")

	self._Host:AddCallableEvent(Usage.Events.DNS_GetServerAddress, Usage.Ports.DNS,
		Task(self.GetDNSServerAddress, self))
	self.Logger:LogDebug('setup Get DNS Server IP Address')

	self._Host:AddEndpoint(Usage.Ports.DNS, "Endpoints", DNSEndpoints --[[@as Net.Rest.Api.Server.EndpointBase]])
	self.Logger:LogDebug('setup DNS Server endpoints')

	self._NetClient = self._Host:GetNetworkClient()
end

function Main:Run()
	self._Host:Ready()
	while true do
		self._NetClient:BroadCast(Usage.Ports.Heartbeats, 'DNS')
		self._Host:RunCycle(3)
	end
end

return Main
