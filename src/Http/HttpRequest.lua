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
