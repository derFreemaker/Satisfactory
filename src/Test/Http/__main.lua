local Uri = require('Net.Rest.Uri')

local EventPullAdapter = require('Core.Event.EventPullAdapter')
local NetworkClient = require('Net.Core.NetworkClient')
local DNSClient = require('DNS.Client.Client')
local HttpClient = require('Net.Http.Client')
local HttpRequest = require('Net.Http.Request')

---@class Test.Http.Main : Github_Loading.Entities.Main
---@field private _NetClient Net.Core.NetworkClient
---@field private _DnsClient DNS.Client
---@field private _HttpClient Net.Http.Client
local Main = {}

function Main:Configure()
	EventPullAdapter:Initialize(self.Logger:subLogger('EventPullAdapter'))

	self._NetClient = NetworkClient(self.Logger:subLogger('NetworkClient'))
	self._DnsClient = DNSClient(self._NetClient, self.Logger:subLogger('DNSClient'))
	self._HttpClient = HttpClient(self.Logger:subLogger('HttpClient'), self._DnsClient)
end

function Main:Run()
	local domain = 'factoryControl.de'

	log("waiting for heartbeat")
	self._DnsClient.Static__WaitForHeartbeat(self._NetClient)
	log("got heartbeat")

	local ipAddress = self._DnsClient:GetOrRequestDNSServerIP()
	log(ipAddress)



	log("creating address")
	local success = self._DnsClient:CreateAddress(domain, self._NetClient:GetIPAddress())
	if not success then
		log('unable to create address on dns server or allready exists')
	else
		log("created address")
	end

	local dnsServerAddress = self._DnsClient:GetOrRequestDNSServerIP()
	log("dns server address", dnsServerAddress)

	local request = HttpRequest('GET', 'AddressWithAddress', Uri.Static__Parse(dnsServerAddress:GetAddress()), domain)
	local response = self._HttpClient:Send(request)
	assert(response:IsSuccess(), 'http request was not successfull')

	---@type DNS.Core.Entities.Address
	local address = response:GetBody()
	assert(address.IPAddress:Equals(self._NetClient:GetIPAddress()),
		"got wrong address id back from dns server '" .. tostring(address.Id) .. "'")

	log(address.Id, address.Url, address.IPAddress)
end

return Main
