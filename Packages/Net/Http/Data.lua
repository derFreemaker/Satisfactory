---@meta
local PackageData = {}

PackageData["NetHttpClient"] = {
    Location = "Net.Http.Client",
    Namespace = "Net.Http.Client",
    IsRunnable = true,
    Data = [[
local PortUsage = require('Core.Usage.Usage_Port')

local IPAddress = require("Net.Core.IPAddress")
local NetworkClient = require('Net.Core.NetworkClient')
local ApiClient = require('Net.Rest.Api.Client.Client')
local DNSClient = require('DNS.Client.Client')
local HttpResponse = require('Net.Http.Response')
local ApiRequest = require('Net.Rest.Api.Request')
local ApiResponse = require('Net.Rest.Api.Response')

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
	self.m_netClient = networkClient or NetworkClient(logger:subLogger('NetworkClient'))
	self.m_dnsClient = dnsClient or DNSClient(self.m_netClient, logger:subLogger('DNSClient'))
	self.m_logger = logger
end

function HttpClient:GetNetworkClient()
	return self.m_netClient
end

---@param address string
---@return Net.Core.IPAddress? address
function HttpClient:GetAddress(address)
	if not address:match('^.*%..*$') then
		return IPAddress(address)
	end

	local cachedAddress = self.m_cache[address]
	if cachedAddress then
		if cachedAddress.ExpireTime > computer.time() then
			return cachedAddress.IPAddress
		end
	end

	local getedAddress = self.m_dnsClient:GetWithDomain(address)
	if not getedAddress then
		self.m_cache[address] = nil
		return nil
	end

	local ipAddress = getedAddress.IPAddress
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
		self.m_logger:subLogger('ApiClient'))

	local apiRequest = ApiRequest(request.Method, request.Uri, request.Body, request.Options.Headers)
	local apiResponse = apiClient:Send(apiRequest, request.Options.Timeout)

	return HttpResponse(apiResponse, request)
end

return Utils.Class.CreateClass(HttpClient, 'Http.HttpClient')
]]
}

PackageData["NetHttpRequest"] = {
    Location = "Net.Http.Request",
    Namespace = "Net.Http.Request",
    IsRunnable = true,
    Data = [[
local Options = require('Net.Http.RequestOptions')

---@class Net.Http.Request : object
---@field Method Net.Core.Method
---@field ServerUrl string
---@field Uri Net.Rest.Uri
---@field Body any
---@field Options Net.Http.Request.Options
---@overload fun(method: Net.Core.Method, ServerUrl: string, Uri: Net.Rest.Uri, body: any, options: Net.Http.Request.Options?) : Net.Http.Request
local HttpRequest = {}

---@private
---@param method Net.Core.Method
---@param serverUrl string
---@param uri Net.Rest.Uri
---@param body any
---@param options Net.Http.Request.Options?
function HttpRequest:__init(method, serverUrl, uri, body, options)
	self.Method = method
	self.ServerUrl = serverUrl
	self.Uri = uri
	self.Body = body
	self.Options = options or Options()
end

return Utils.Class.CreateClass(HttpRequest, "Net.Http.HttpRequest")
]]
}

PackageData["NetHttpRequestOptions"] = {
    Location = "Net.Http.RequestOptions",
    Namespace = "Net.Http.RequestOptions",
    IsRunnable = true,
    Data = [[
---@class Net.Http.Request.Options : object
---@field Headers table<string, any>
---@field Timeout integer in seconds
---@overload fun() : Net.Http.Request.Options
local HttpRequestOptions = {}

---@private
function HttpRequestOptions:__init()
	self.Headers = {}
	self.Timeout = 10
end

return Utils.Class.CreateClass(HttpRequestOptions, 'Http.HttpRequestOptions')
]]
}

PackageData["NetHttpResponse"] = {
    Location = "Net.Http.Response",
    Namespace = "Net.Http.Response",
    IsRunnable = true,
    Data = [[
---@class Net.Http.Response : object
---@field ApiResponse Net.Rest.Api.Response
---@field Request Net.Http.Request
---@overload fun(apiResponse: Net.Rest.Api.Response, request: Net.Http.Request) : Net.Http.Response
local HttpResponse = {}

---@private
---@param apiResponse Net.Rest.Api.Response
---@param request Net.Http.Request
function HttpResponse:__init(apiResponse, request)
	self.ApiResponse = apiResponse
	self.Request = request
end

---@return boolean
function HttpResponse:IsSuccess()
	return self.ApiResponse.WasSuccessful
end

function HttpResponse:IsFaulted()
	return not self:IsSuccess()
end

---@return any
function HttpResponse:GetBody()
	return self.ApiResponse.Body
end

---@return Net.Core.StatusCodes
function HttpResponse:GetStatusCode()
	return self.ApiResponse.Headers.Code
end

return Utils.Class.CreateClass(HttpResponse, 'Http.HttpResponse')
]]
}

return PackageData
