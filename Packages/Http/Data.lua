local PackageData = {}

PackageData.AEMBAHeA = {
    Location = "Http.HttpClient",
    Namespace = "Http.HttpClient",
    IsRunnable = true,
    Data = [[
local NetworkClient = require('Net.Core.NetworkClient')
local DNSClient = require('DNS.Client.DNSClient')

---@class Http.HttpClient : object
---@field private netClient Net.Core.NetworkClient
---@field private dnsClient DNS.Client
---@field private logger Core.Logger
---@overload fun(logger: Core.Logger, dnsClient: DNS.Client, networkClient: Net.Core.NetworkClient?) : Http.HttpClient
local HttpClient = {}

---@param logger Core.Logger
---@param dnsClient DNS.Client
---@param networkClient Net.Core.NetworkClient?
function HttpClient:__init(logger, dnsClient, networkClient)
	self.netClient = networkClient or NetworkClient(logger:subLogger('NetworkClient'))
	self.dnsClient = dnsClient or DNSClient(self.netClient, logger:subLogger('DNSClient'))
	self.logger = logger
end

---@param method Net.Rest.Api.Method
---@param endpoint string
---@param body any
---@param options Http.HttpRequestOptions
function HttpClient:Request(method, endpoint, body, options)
	-- //TODO: process request
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
---@field Method Net.Rest.Api.Method
---@field Endpoint string
---@field Body any
---@field Options Http.HttpRequestOptions
---@field private Client Http.HttpClient
---@overload fun(method: Net.Rest.Api.Method, endpoint: string, body: any, options: Http.HttpRequestOptions, client: Http.HttpClient) : Http.HttpRequest
local HttpRequest = {}

---@private
---@param method Net.Rest.Api.Method
---@param endpoint string
---@param options Http.HttpRequestOptions
---@param client Http.HttpClient
function HttpRequest:__init(method, endpoint, body, options, client)
	self.Client = client
end

function HttpRequest:Send()
	self.Client:Request(self.Method, self.Endpoint, self.Body, self.Options)
end

-- //TODO: request

return Utils.Class.CreateClass(HttpRequest, 'Http.HttpRequest')
]]
}

PackageData.CjgXvuZA = {
    Location = "Http.HttpRequestOptions",
    Namespace = "Http.HttpRequestOptions",
    IsRunnable = true,
    Data = [[
---@class Http.HttpRequestOptions : object
---@field Headers Dictionary<string, any>
---@overload fun() : Http.HttpRequestOptions
local HttpRequestOptions = {}

---@private
function HttpRequestOptions:__init()
	self.Headers = {}
end

return Utils.Class.CreateClass(HttpRequestOptions, 'Http.HttpRequestOptions')
]]
}

return PackageData
