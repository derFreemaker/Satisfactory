---@meta
local PackageData = {}

PackageData["DNSClientClient"] = {
    Location = "DNS.Client.Client",
    Namespace = "DNS.Client.Client",
    IsRunnable = true,
    Data = [[
local PortUsage = require('Core.PortUsage')

local IPAddress = require("Net.Core.IPAddress")
local NetworkClient = require('Net.Core.NetworkClient')
local ApiClient = require('Net.Rest.Api.Client.Client')
local ApiRequest = require('Net.Rest.Api.Request')

local Address = require('DNS.Core.Entities.Address.Address')
local CreateAddress = require('DNS.Core.Entities.Address.Create')

---@class DNS.Client : object
---@field private networkClient Net.Core.NetworkClient
---@field private apiClient Net.Rest.Api.Client
---@field private logger Core.Logger
---@overload fun(networkClient: Net.Core.NetworkClient, logger: Core.Logger) : DNS.Client
local Client = {}

---@private
---@param networkClient Net.Core.NetworkClient?
---@param logger Core.Logger
function Client:__init(networkClient, logger)
	self.networkClient = networkClient or NetworkClient(logger:subLogger('NetworkClient'))
	self.logger = logger
end

---@return Net.Core.NetworkClient
function Client:GetNetClient()
	return self.networkClient
end

---@param networkClient Net.Core.NetworkClient
function Client.Static_WaitForHeartbeat(networkClient)
	networkClient:WaitForEvent('DNS', PortUsage.Heartbeats)
end

---@param networkClient Net.Core.NetworkClient
---@return Net.Core.IPAddress id
function Client.Static__GetServerAddress(networkClient)
	Client.Static_WaitForHeartbeat(networkClient)
	local netPort = networkClient:CreateNetworkPort(PortUsage.DNS)

	netPort:BroadCastMessage('GetDNSServerAddress', nil, nil)
	---@type Net.Core.NetworkContext?
	local response
	local try = 0
	repeat
		try = try + 1
		response = netPort:WaitForEvent('ReturnDNSServerAddress', 10)
	until response ~= nil or try == 10
	if try == 10 then
		error('unable to get dns server address')
	end
	---@cast response Net.Core.NetworkContext
	return IPAddress(response.Body)
end

---@return Net.Core.IPAddress id
function Client:RequestOrGetDNSServerIP()
	if not self.apiClient then
		self.Static_WaitForHeartbeat(self.networkClient)

		local serverIPAddress = Client.Static__GetServerAddress(self.networkClient)
		self.apiClient = ApiClient(serverIPAddress, PortUsage.HTTP, PortUsage.HTTP, self.networkClient,
			self.logger:subLogger('ApiClient'))
	end

	return self.apiClient.ServerIPAddress
end

---@private
---@param request Net.Rest.Api.Request
function Client:InternalRequest(request)
	Client.Static_WaitForHeartbeat(self.networkClient)
	self:RequestOrGetDNSServerIP()

	return self.apiClient:Send(request)
end

---@param address string
---@param id string
---@return boolean success
function Client:CreateAddress(address, id)
	local createAddress = CreateAddress(address, id)

	local request = ApiRequest('CREATE', 'Address', createAddress:ExtractData())
	local response = self:InternalRequest(request)

	if not response.WasSuccessfull then
		return false
	end
	return response.Body
end

---@param address string
---@return boolean success
function Client:DeleteAddress(address)
	local request = ApiRequest('DELETE', 'Address', address)
	local response = self:InternalRequest(request)

	if not response.WasSuccessfull then
		return false
	end
	return response.Body
end

---@param address string
---@return DNS.Core.Entities.Address? address
function Client:GetWithAddress(address)
	local request = ApiRequest('GET', 'AddressWithAddress', address)
	local response = self:InternalRequest(request)

	if not response.WasSuccessfull then
		return nil
	end
	return Address:Static__CreateFromData(response.Body)
end

---@param id string
---@return DNS.Core.Entities.Address? address
function Client:GetWithId(id)
	local request = ApiRequest('GET', 'AddressWithId', id)
	local response = self:InternalRequest(request)

	if not response.WasSuccessfull then
		return nil
	end
	return Address:Static__CreateFromData(response.Body)
end

return Utils.Class.CreateClass(Client, 'DNS.Client')
]]
}

return PackageData
