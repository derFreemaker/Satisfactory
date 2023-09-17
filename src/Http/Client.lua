local NetworkClient = require('Net.Core.NetworkClient')
local DNSClient = require('DNS.Client.Client')
local HttpRequest = require('Http.Request')
local HttpResponse = require('Http.Response')
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

---@param method Net.Core.Method
---@param endpoint string
---@param body any
---@param options Http.HttpRequest.Options
---@return Http.HttpResponse response
function HttpClient:Request(method, endpoint, body, options)
	return self:Send(HttpRequest(method, endpoint, body, options))
end

---@param request Http.HttpRequest
---@return Http.HttpResponse response
function HttpClient:Send(request)
	-- //TODO: process request

	return HttpResponse(ApiResponse(nil, {Code = 400}), request)
end

return Utils.Class.CreateClass(HttpClient, 'Http.HttpClient')
