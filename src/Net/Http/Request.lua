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

return Utils.Class.Create(HttpRequest, "Net.Http.HttpRequest")
