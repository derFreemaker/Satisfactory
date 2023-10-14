local Options = require('Net.Http.RequestOptions')

---@class Http.Request : object
---@field Method Net.Core.Method
---@field Endpoint string
---@field Address string
---@field Body any
---@field Options Http.Request.Options
---@overload fun(method: Net.Core.Method, endpoint: string, address: string, body: any, options: Http.Request.Options?) : Http.Request
local HttpRequest = {}

---@private
---@param method Net.Core.Method
---@param endpoint string
---@param address string
---@param body any
---@param options Http.Request.Options?
function HttpRequest:__init(method, endpoint, address, body, options)
	self.Method = method
	self.Endpoint = endpoint
	self.Address = address
	self.Body = body
	self.Options = options or Options()
end

return Utils.Class.CreateClass(HttpRequest, 'Http.HttpRequest')
