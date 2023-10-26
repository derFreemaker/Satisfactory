local PortUsage = require('Core.Usage.Usage_Port')

local IPAddress = require("Net.Core.IPAddress")
local NetworkClient = require('Net.Core.NetworkClient')
local ApiClient = require('Net.Rest.Api.Client.Client')
local DNSClient = require('DNS.Client.Client')
local HttpResponse = require('Net.Http.Response')
local ApiRequest = require('Net.Rest.Api.Request')
local ApiResponse = require('Net.Rest.Api.Response')

---@class Net.Http.Client : object
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

	self.m_netClient = networkClient or NetworkClient(logger:subLogger('NetworkClient'))
	self.m_dnsClient = dnsClient or DNSClient(self.m_netClient, logger:subLogger('DNSClient'))
	self.m_logger = logger
end

---@private
---@param address string
---@return Net.Core.IPAddress? address
function HttpClient:getAddress(address)
	if not address:match('^.*%..*$') then
		return IPAddress(address)
	end

	local getedAddress = self.m_dnsClient:GetWithId(address)
	if not getedAddress then
		return nil
	end

	return IPAddress(getedAddress.Id)
end

---@param request Net.Http.Request
---@return Net.Http.Response response
function HttpClient:Send(request)
	local address = self:getAddress(request.ServerUrl)
	if not address then
		return HttpResponse(ApiResponse(nil, { Code = 404 }), request)
	end

	local apiClient = ApiClient(address, PortUsage.HTTP, PortUsage.HTTP, self.m_netClient,
		self.m_logger:subLogger('ApiClient'))

	local apiRequest = ApiRequest(request.Method, request.Uri, request.Body, request.Options.Headers)
	local apiResponse = apiClient:Send(apiRequest, request.Options.Timeout)

	return HttpResponse(apiResponse, request)
end

return Utils.Class.CreateClass(HttpClient, 'Http.HttpClient')
