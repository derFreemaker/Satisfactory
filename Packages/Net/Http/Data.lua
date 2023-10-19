---@meta
local PackageData = {}

PackageData["NetHttpClient"] = {
    Location = "Net.Http.Client",
    Namespace = "Net.Http.Client",
    IsRunnable = true,
    Data = [[
local PortUsage = require('Core.Usage_Port')

local IPAddress = require("Net.Core.IPAddress")
local NetworkClient = require('Net.Core.NetworkClient')
local ApiClient = require('Net.Rest.Api.Client.Client')
local DNSClient = require('DNS.Client.Client')
local HttpResponse = require('Net.Http.Response')
local ApiRequest = require('Net.Rest.Api.Request')
local ApiResponse = require('Net.Rest.Api.Response')

---@class Net.Http.Client : object
---@field private _NetClient Net.Core.NetworkClient
---@field private _DnsClient DNS.Client
---@field private _Logger Core.Logger
---@overload fun(logger: Core.Logger, dnsClient: DNS.Client?, networkClient: Net.Core.NetworkClient?) : Net.Http.Client
local HttpClient = {}

---@param logger Core.Logger
---@param dnsClient DNS.Client?
---@param networkClient Net.Core.NetworkClient?
function HttpClient:__init(logger, dnsClient, networkClient)
	if dnsClient and not networkClient then
		networkClient = dnsClient:GetNetClient()
	end

	self._NetClient = networkClient or NetworkClient(logger:subLogger('NetworkClient'))
	self._DnsClient = dnsClient or DNSClient(self._NetClient, logger:subLogger('DNSClient'))
	self._Logger = logger
end

---@private
---@param address string
---@return Net.Core.IPAddress? address
function HttpClient:getAddress(address)
	if not address:match('^.*%..*$') then
		return IPAddress(address)
	end

	local getedAddress = self._DnsClient:GetWithUrl(address)
	if not getedAddress then
		return nil
	end

	return IPAddress(getedAddress.Id)
end

---@param request Net.Http.Request
---@return Net.Http.Response response
function HttpClient:Send(request)
	local address = self:getAddress(request.Url)
	if not address then
		return HttpResponse(ApiResponse(nil, { Code = 404 }), request)
	end

	local apiClient = ApiClient(address, PortUsage.HTTP, PortUsage.HTTP, self._NetClient,
		self._Logger:subLogger('ApiClient'))

	local apiRequest = ApiRequest(request.Method, request.Endpoint, request.Body, request.Options.Headers)
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
---@field Endpoint string
---@field Url string
---@field Body any
---@field Options Net.Http.Request.Options
---@overload fun(method: Net.Core.Method, endpoint: string, url: string, body: any, options: Net.Http.Request.Options?) : Net.Http.Request
local HttpRequest = {}

---@private
---@param method Net.Core.Method
---@param endpoint string
---@param url string
---@param body any
---@param options Net.Http.Request.Options?
function HttpRequest:__init(method, endpoint, url, body, options)
	self.Method = method
	self.Endpoint = endpoint
	self.Url = url
	self.Body = body
	self.Options = options or Options()
end

return Utils.Class.CreateClass(HttpRequest, 'Http.HttpRequest')
]]
}

PackageData["NetHttpRequestOptions"] = {
    Location = "Net.Http.RequestOptions",
    Namespace = "Net.Http.RequestOptions",
    IsRunnable = true,
    Data = [[
---@class Net.Http.Request.Options : object
---@field Headers Dictionary<string, any>
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
	return self.ApiResponse.WasSuccessfull
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
