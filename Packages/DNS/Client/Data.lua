local PackageData = {}

PackageData.kyXCjvQy = {
    Location = "DNS.Client.Client",
    Namespace = "DNS.Client.Client",
    IsRunnable = true,
    Data = [[
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

---@return string id
function Client:GetDNSServerAddressIfNeeded()
	if not self.apiClient then
		local serverIPAddress = self:Static__GetServerAddress(self.networkClient)
		self.apiClient = ApiClient(serverIPAddress, 80, 80, self.networkClient, self.logger:subLogger('ApiClient'))
	end

	return self.apiClient.ServerIPAddress
end

---@param address string
---@param id string
---@return boolean success
function Client:CreateAddress(address, id)
	self:GetDNSServerAddressIfNeeded()

	local createAddress = CreateAddress(address, id)

	local request = ApiRequest('CREATE', 'Address', createAddress:ExtractData())
	local response = self.apiClient:request(request)

	if not response.WasSuccessfull then
		return false
	end
	return response.Body
end

---@param address string
---@return boolean success
function Client:DeleteAddress(address)
	self:GetDNSServerAddressIfNeeded()

	local request = ApiRequest('DELETE', 'Address', address)
	local response = self.apiClient:request(request)

	if not response.WasSuccessfull then
		return false
	end
	return response.Body
end

---@param address string
---@return DNS.Core.Entities.Address? address
function Client:GetWithAddress(address)
	self:GetDNSServerAddressIfNeeded()

	local request = ApiRequest('GET', 'AddressWithAddress', address)
	local response = self.apiClient:request(request)

	if not response.WasSuccessfull then
		return nil
	end
	return Address:Static__CreateFromData(response.Body)
end

---@param id string
---@return DNS.Core.Entities.Address? address
function Client:GetWithId(id)
	self:GetDNSServerAddressIfNeeded()

	local request = ApiRequest('GET', 'AddressWithId', id)
	local response = self.apiClient:request(request)

	if not response.WasSuccessfull then
		return nil
	end
	return Address:Static__CreateFromData(response.Body)
end

---@param networkClient Net.Core.NetworkClient
---@return string id
function Client:Static__GetServerAddress(networkClient)
	local netPort = networkClient:CreateNetworkPort(53)

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
	return response.Body
end

return Utils.Class.CreateClass(Client, 'DNS.Client')
]]
}

return PackageData
