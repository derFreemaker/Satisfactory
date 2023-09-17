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
