local Usage = require("Core.Usage.Usage")

local IPAddress = require("Net.Core.IPAddress")
local NetworkClient = require('Net.Core.NetworkClient')
local ApiClient = require('Net.Rest.Api.Client.Client')
local ApiRequest = require('Net.Rest.Api.Request')

local CreateAddress = require('DNS.Core.Entities.Address.Create')

local Uri = require("Net.Rest.Uri")

---@class DNS.Client : object
---@field private _NetworkClient Net.Core.NetworkClient
---@field private _ApiClient Net.Rest.Api.Client
---@field private _Logger Core.Logger
---@overload fun(networkClient: Net.Core.NetworkClient, logger: Core.Logger) : DNS.Client
local Client = {}

---@private
---@param networkClient Net.Core.NetworkClient?
---@param logger Core.Logger
function Client:__init(networkClient, logger)
	self._NetworkClient = networkClient or NetworkClient(logger:subLogger('NetworkClient'))
	self._Logger = logger
end

---@return Net.Core.NetworkClient
function Client:GetNetClient()
	return self._NetworkClient
end

---@param networkClient Net.Core.NetworkClient
function Client.Static_WaitForHeartbeat(networkClient)
	networkClient:WaitForEvent(Usage.Events.DNS_Heartbeat, Usage.Ports.Heartbeats)
end

---@param networkClient Net.Core.NetworkClient
---@return Net.Core.IPAddress id
function Client.Static__GetServerAddress(networkClient)
	local netPort = networkClient:GetOrCreateNetworkPort(Usage.Ports.DNS)

	netPort:BroadCastMessage(Usage.Events.DNS_GetServerAddress, nil, nil)
	---@type Net.Core.NetworkContext?
	local response
	local try = 0
	repeat
		try = try + 1
		response = netPort:WaitForEvent(Usage.Events.DNS_ReturnServerAddress, 10)
	until response ~= nil or try == 10
	if try == 10 then
		error('unable to get dns server address')
	end
	---@cast response Net.Core.NetworkContext
	return IPAddress(response.Body)
end

---@return Net.Core.IPAddress id
function Client:RequestOrGetDNSServerIP()
	if not self._ApiClient then
		local serverIPAddress = Client.Static__GetServerAddress(self._NetworkClient)
		self._ApiClient = ApiClient(serverIPAddress, Usage.Ports.HTTP, Usage.Ports.HTTP, self._NetworkClient,
			self._Logger:subLogger('ApiClient'))
	end

	return self._ApiClient.ServerIPAddress
end

---@private
---@param method Net.Core.Method
---@param url string
---@param body any
---@param headers Dictionary<string, any>?
function Client:InternalRequest(method, url, body, headers)
	self:RequestOrGetDNSServerIP()

	local request = ApiRequest(method, Uri(url), body, headers)
	return self._ApiClient:Send(request)
end

---@param url string
---@param ipAddress Net.Core.IPAddress
---@return boolean success
function Client:CreateAddress(url, ipAddress)
	local createAddress = CreateAddress(url, ipAddress)

	local response = self:InternalRequest('CREATE', '/Address/Create', createAddress)

	if not response.WasSuccessfull then
		return false
	end
	return response.Body
end

---@param id Core.UUID
---@return boolean success
function Client:DeleteAddress(id)
	local response = self:InternalRequest('DELETE', "/Address/" .. tostring(id) .. "/Delete")

	if not response.WasSuccessfull then
		return false
	end
	return response.Body
end

---@param id Core.UUID
---@return DNS.Core.Entities.Address? address
function Client:GetWithUrl(id)
	local response = self:InternalRequest('GET', "/Address/Id/" .. tostring(id))

	if not response.WasSuccessfull then
		return nil
	end
	return response.Body
end

---@param url string
---@return DNS.Core.Entities.Address? address
function Client:GetWithIPAddress(url)
	local response = self:InternalRequest('GET', "/Address/Url/" .. url)

	if not response.WasSuccessfull then
		return nil
	end
	return response.Body
end

return Utils.Class.CreateClass(Client, 'DNS.Client')
