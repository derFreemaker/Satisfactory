local PortUsage = require("Core.Usage.Usage_Port")

local IPAddress = require("Net.Core.IPAddress")
local NetworkClient = require("Net.Core.NetworkClient")
local ApiClient = require("Net.Rest.Api.Client.Client")
local DNSClient = require("DNS.Client.Client")
local HttpResponse = require("Net.Http.Response")
local ApiRequest = require("Net.Rest.Api.Core.Request")
local ApiResponse = require("Net.Rest.Api.Core.Response")

---@alias Net.Http.Client.CachedAddress { ExpireTime: integer, IPAddress: Net.Core.IPAddress }

---@class Net.Http.Client : object
---@field private m_cache table<string, Net.Http.Client.CachedAddress>
---@field private m_netClient Net.Core.NetworkClient
---@field private m_dnsClient DNS.Client
---@field private m_logger Core.Logger
---@overload fun(logger: Core.Logger, dnsClient: DNS.Client?, networkClient: Net.Core.NetworkClient?) : Net.Http.Client
local HttpClient = {}

---@param logger Core.Logger
---@param dnsClient DNS.Client?
---@param networkClient Net.Core.NetworkClient?
function HttpClient:__init(logger, dnsClient, networkClient)
	if dnsClient and not networkClient then
		networkClient = dnsClient:GetNetClient()
	end

	self.m_cache = {}
	self.m_netClient = networkClient or NetworkClient(logger:subLogger("NetworkClient"))
	self.m_dnsClient = dnsClient or DNSClient(self.m_netClient, logger:subLogger("DNSClient"))
	self.m_logger = logger
end

function HttpClient:GetNetworkClient()
	return self.m_netClient
end

---@param address string
---@return Net.Core.IPAddress? address
function HttpClient:GetAddress(address)
	if not address:match("^.*%..*$") then
		return IPAddress(address)
	end

	local cachedAddress = self.m_cache[address]
	if cachedAddress then
		if cachedAddress.ExpireTime > computer.time() then
			return cachedAddress.IPAddress
		end
	end

	local gotAddress = self.m_dnsClient:GetWithDomain(address)
	if not gotAddress then
		self.m_cache[address] = nil
		return nil
	end

	local ipAddress = gotAddress.IPAddress
	self.m_cache[address] = {
		ExpireTime = computer.time() + 7200,
		IPAddress = ipAddress
	}

	return ipAddress
end

---@param request Net.Http.Request
---@return Net.Http.Response response
function HttpClient:Send(request)
	local address = self:GetAddress(request.ServerUrl)
	if not address then
		return HttpResponse(ApiResponse(nil, { Code = 404 }), request)
	end

	local apiClient = ApiClient(address, PortUsage.HTTP, PortUsage.HTTP, self.m_netClient,
		self.m_logger:subLogger("ApiClient"))

	local apiRequest = ApiRequest(request.Method, request.Uri, request.Body, request.Options.Headers)
	local apiResponse = apiClient:Send(apiRequest, request.Options.Timeout)

	return HttpResponse(apiResponse, request)
end

return class("Http.HttpClient", HttpClient)
