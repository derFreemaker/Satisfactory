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
