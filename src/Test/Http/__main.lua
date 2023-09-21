local EventPullAdapter = require('Core.Event.EventPullAdapter')
local NetworkClient = require('Net.Core.NetworkClient')
local DNSClient = require('DNS.Client.Client')
local HttpClient = require('Net.Http.Client')
local HttpRequest = require('Net.Http.Request')
local Address = require('DNS.Core.Entities.Address.Address')

---@class Test.Http.Main : Github_Loading.Entities.Main
---@field private netClient Net.Core.NetworkClient
---@field private dnsClient DNS.Client
---@field private httpClient Http.Client
local Main = {}

function Main:Configure()
	EventPullAdapter:Initialize(self.Logger:subLogger('EventPullAdapter'))

	self.netClient = NetworkClient(self.Logger:subLogger('NetworkClient'))
	self.dnsClient = DNSClient(self.netClient, self.Logger:subLogger('DNSClient'))
	self.httpClient = HttpClient(self.Logger:subLogger('HttpClient'), self.dnsClient)
end

function Main:Run()
	local domain = 'factoryControl.de'

	local success = self.dnsClient:CreateAddress(domain, self.netClient:GetId())
	assert(success, 'unable to create address on dns server')

	local request = HttpRequest('GET', 'AddressWithAddress', self.dnsClient:GetDNSServerAddressIfNeeded(), domain)
	local response = self.httpClient:Send(request)
	assert(response:IsSuccess(), 'http request was not successfull')

	local address = Address:Static__CreateFromData(response:GetBody())
	assert(address.Id == self.netClient:GetId(), "got wrong address id back from dns server '" .. tostring(address.Id) .. "'")

	log(address.Address, address.Id)
end

return Main
