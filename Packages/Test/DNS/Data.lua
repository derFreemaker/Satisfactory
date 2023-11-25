---@meta
local PackageData = {}

PackageData["TestDNS__main"] = {
    Location = "Test.DNS.__main",
    Namespace = "Test.DNS.__main",
    IsRunnable = true,
    Data = [[
local EventPullAdapter = require('Core.Event.EventPullAdapter')
local NetworkClient = require('Net.Core.NetworkClient')
local DNSClient = require('DNS.Client.Client')

---@class Test.DNS.Main : Github_Loading.Entities.Main
---@field private m_netClient Net.Core.NetworkClient
---@field private m_dnsClient DNS.Client
local Main = {}

function Main:Configure()
	EventPullAdapter:Initialize(self.Logger:subLogger('EventPullAdapter'))

	self.m_netClient = NetworkClient(self.Logger:subLogger('NetworkClient'))
	self.m_dnsClient = DNSClient(self.m_netClient, self.Logger:subLogger('DNSClient'))
end

function Main:Run()
	log("running test")

	local domain = 'factoryControl'

	log("waiting for heartbeat...")
	self.m_dnsClient.Static__WaitForHeartbeat(self.m_netClient)
	log("got heartbeat")

	local dnsServerAddress = self.m_dnsClient:GetOrRequestDNSServerIP()
	log("dns server address:", dnsServerAddress)

	log("creating address...")
	local success = self.m_dnsClient:CreateAddress(domain, self.m_netClient:GetIPAddress())
	if not success then
		log('unable to create address on dns server or allready exists')
	else
		log("created address")
	end

	log("getting address...")
	local address = self.m_dnsClient:GetWithDomain(domain)

	assert(address ~= nil, 'http request was not successful')

	assert(address.IPAddress:Equals(self.m_netClient:GetIPAddress()),
		"got wrong address id back from dns server '" .. tostring(address.Id) .. "'")

	log("got address", address.Id, address.Domain, address.IPAddress)

	log("test passed")
end

return Main
]]
}

return PackageData
