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
