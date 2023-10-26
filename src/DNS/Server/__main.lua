local Usage = require("Core.Usage.Usage")

local Task = require('Core.Task')

local Host = require("Hosting.Host")

local DNSEndpoints = require('DNS.Server.Endpoints')

---@class DNS.Main : Github_Loading.Entities.Main
---@field private m_netClient Net.Core.NetworkClient
---@field private m_host Hosting.Host
local Main = {}

---@param context Net.Core.NetworkContext
function Main:GetDNSServerAddress(context)
	local id = self.m_netClient:GetIPAddress():GetAddress()
	self.Logger:LogDebug(context.SenderIPAddress:GetAddress(), 'requested DNS Server IP Address')
	self.m_netClient:Send(context.SenderIPAddress, Usage.Ports.DNS, Usage.Events.DNS_ReturnServerAddress, id)
end

function Main:Configure()
	self.m_host = Host(self.Logger:subLogger("Host"), "DNS")

	self.m_host:AddCallableEvent(Usage.Events.DNS_GetServerAddress, Usage.Ports.DNS,
		Task(self.GetDNSServerAddress, self))
	self.Logger:LogDebug('setup Get DNS Server IP Address')

	self.m_host:AddEndpoint(Usage.Ports.HTTP, "Endpoints", DNSEndpoints --[[@as Net.Rest.Api.Server.EndpointBase]])
	self.Logger:LogDebug('setup DNS Server endpoints')

	self.m_netClient = self.m_host:GetNetworkClient()
end

function Main:Run()
	self.m_host:Ready()
	while true do
		self.m_netClient:BroadCast(Usage.Ports.Heartbeats, 'DNS')
		self.m_host:RunCycle(20)
	end
end

return Main
