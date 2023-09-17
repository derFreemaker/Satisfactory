local PackageData = {}

PackageData.AEMBAHeA = {
    Location = "Http.HttpClient",
    Namespace = "Http.HttpClient",
    IsRunnable = true,
    Data = [[
local NetworkClient = require('Net.Core.NetworkClient')
local DNSClient = require('DNS.Client.DNSClient')
local Request = require('Http.HttpRequest')
local Response = require('Http.HttpResponse')

local StatusCodes = require('Net.Core.StatusCodes')

---@class Http.HttpClient : object
---@field private netClient Net.Core.NetworkClient
---@field private dnsClient DNS.Client
---@field private logger Core.Logger
---@overload fun(logger: Core.Logger, dnsClient: DNS.Client?, networkClient: Net.Core.NetworkClient?) : Http.HttpClient
local HttpClient = {}

---@param logger Core.Logger
---@param dnsClient DNS.Client?
---@param networkClient Net.Core.NetworkClient?
function HttpClient:__init(logger, dnsClient, networkClient)
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
	return self:Send(Request(method, endpoint, body, options))
end

---@param request Http.HttpRequest
---@return Http.HttpResponse response
function HttpClient:Send(request)
	-- //TODO: process request

	return Response(nil, StatusCodes.Status400BadRequest, request)
end

return Utils.Class.CreateClass(HttpClient, 'Http.HttpClient')
]]
}

PackageData.bTwMXABa = {
    Location = "Http.HttpRequest",
    Namespace = "Http.HttpRequest",
    IsRunnable = true,
    Data = [[
---@class Http.HttpRequest : object
---@field Method Net.Core.Method
---@field Endpoint string
---@field Body any
---@field Options Http.HttpRequest.Options
---@overload fun(method: Net.Core.Method, endpoint: string, body: any, options: Http.HttpRequest.Options) : Http.HttpRequest
local HttpRequest = {}

---@private
---@param method Net.Core.Method
---@param endpoint string
---@param options Http.HttpRequest.Options
function HttpRequest:__init(method, endpoint, body, options)
	self.Method = method
	self.Endpoint = endpoint
	self.Body = body
	self.Options = options
end

return Utils.Class.CreateClass(HttpRequest, 'Http.HttpRequest')
]]
}

PackageData.CjgXvuZA = {
    Location = "Http.HttpRequestOptions",
    Namespace = "Http.HttpRequestOptions",
    IsRunnable = true,
    Data = [[
---@class Http.HttpRequest.Options : object
---@field Headers Dictionary<string, any>
---@field Timeout integer in seconds
---@overload fun() : Http.HttpRequest.Options
local HttpRequestOptions = {}

---@private
function HttpRequestOptions:__init()
	self.Headers = {}
	self.Timeout = 10
end

return Utils.Class.CreateClass(HttpRequestOptions, 'Http.HttpRequestOptions')
]]
}

PackageData.eyRiSnwa = {
    Location = "Http.HttpResponse",
    Namespace = "Http.HttpResponse",
    IsRunnable = true,
    Data = [[
---@class Http.HttpResponse : object
---@field Result any
---@field StatusCodes Net.Core.StatusCodes
---@field Request Http.HttpRequest
---@overload fun(result: any, statusCodes: Net.Core.StatusCodes, request: Http.HttpRequest) : Http.HttpResponse
local HttpResponse = {}

---@private
---@param result any
---@param statusCodes Net.Core.StatusCodes
---@param request Http.HttpRequest
function HttpResponse:__init(result, statusCodes, request)
	self.Result = result
	self.StatusCodes = statusCodes
	self.Request = request
end

return Utils.Class.CreateClass(HttpResponse, 'Http.HttpResponse')
]]
}

return PackageData
