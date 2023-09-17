local NetworkClient = require('Net.Core.NetworkClient')
local ApiClient = require('Net.Rest.Api.Client.Client')
local DNSClient = require('DNS.Client.Client')
local HttpRequest = require('Http.Request')
local HttpResponse = require('Http.Response')
local ApiRequest = require('Net.Rest.Api.Request')
local ApiResponse = require('Net.Rest.Api.Response')

---@class Http.Client : object
---@field private netClient Net.Core.NetworkClient
---@field private dnsClient DNS.Client
---@field private logger Core.Logger
---@overload fun(logger: Core.Logger, dnsClient: DNS.Client?, networkClient: Net.Core.NetworkClient?) : Http.Client
local HttpClient = {}

---@param logger Core.Logger
---@param dnsClient DNS.Client?
---@param networkClient Net.Core.NetworkClient?
function HttpClient:__init(logger, dnsClient, networkClient)
	if dnsClient and not networkClient then
		networkClient = dnsClient:GetNetClient()
	end

	self.netClient = networkClient or NetworkClient(logger:subLogger('NetworkClient'))
	self.dnsClient = dnsClient or DNSClient(self.netClient, logger:subLogger('DNSClient'))
	self.logger = logger
end

---@param request Http.Request
---@return Http.Response response
function HttpClient:Send(request)
	local address = self.dnsClient:GetWithAddress(request.Address)
	if not address then
		return HttpResponse(ApiResponse(nil, {Code = 404}), request)
	end

	local apiClient = ApiClient(address.Id, 80, 80, self.netClient, self.logger:subLogger('ApiClient'))

	local apiRequest = ApiRequest(request.Method, request.Endpoint, request.Body, request.Options.Headers)
	local apiResponse = apiClient:Request(apiRequest, request.Options.Timeout)

	return HttpResponse(apiResponse, request)
end

---@param method Net.Core.Method
---@param endpoint string
---@param body any
---@param options Http.Request.Options
---@return Http.Response response
function HttpClient:Request(method, endpoint, body, options)
	return self:Send(HttpRequest(method, endpoint, body, options))
end

return Utils.Class.CreateClass(HttpClient, 'Http.HttpClient')
